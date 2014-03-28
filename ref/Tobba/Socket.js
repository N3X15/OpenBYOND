DM.Socket = function(host, port) {
	this.name = "socket" + Math.floor(Math.random() * 1000000);
	var elem = document.createElement('span');
	elem.id = this.name;
	document.body.appendChild(elem); // TODO: need to put these in some off-screen "socket holder" object
	swfobject.embedSWF("DM/socket_bridge.swf", elem, "1", "1", "9.0.0","expressInstall.swf", {'scope' : this.name}, {}, {'allowscriptaccess' : 'always'});
	// FIXME: this hex conversion stuff is going to be SLOW
	window[this.name] = this;
	
	this.loaded = function() {
		this.swf = document.getElementById(this.name);
		this.swf.connect(host, String(port));
	}
	
	this.connected = function() {
		this.onconnect();
	}
	
	this.header = new Uint8Array(4);
	this.headerLength = 0;
	this.activePacket;
	this.packetPosition = 0;
	this.receive = function(msg) {
		var bytes = new Uint8Array(msg.length/2);
		for (var i = 0; i < msg.length; i += 2)
			bytes[i/2] = parseInt(msg.charAt(i)+msg.charAt(i+1), 16);
		
		var p = 0;
		while (p < bytes.length)
		{
			if (this.headerLength < 4)
			{
				for (; this.headerLength < 4 && bytes.length-p > 0; this.headerLength++)
					this.header[this.headerLength] = bytes[p++];
			}
			if (this.headerLength >= 4)
			{
				if (!this.activePacket)
					this.activePacket = new DM.Packet(this.header[0] * 0x100 + this.header[1], this.header[2] * 0x100 + this.header[3]);
				for (; this.packetPosition < this.activePacket.data.length && bytes.length-p > 0; this.packetPosition++)
					this.activePacket.data[this.packetPosition] = bytes[p++];
				if (this.packetPosition >= this.activePacket.data.length)
				{
					var packet = this.activePacket;
					this.activePacket = null;
					this.headerLength = 0;
					this.packetPosition = 0;
					
					this.onreceive(packet); // TODO: wrap handler in try/catch to prevent full breakage
				}
			}
		}
	}
	
	// TODO: handle all callbacks
	
	var lookup = {}
	for (var i = 0; i < 256; i++)
		lookup[i] = ('00'+i.toString(16)).substr(-2);
	
	this.SetSequence = function(seq) {
		this.sequence = seq;
	}
	
	this.Send = function(packet) {
		var msg = ('0000'+packet.id.toString(16)).substr(-4) + ('0000'+packet.data.length.toString(16)).substr(-4);
		if (this.sequence)
		{
			msg = ('0000'+this.sequence.toString(16)).substr(-4) +  msg;
			this.sequence = (17364 * this.sequence) % 0xFFF1;
			if (this.sequence == 0)
				this.sequence = 1;
		}
		for (var i = 0; i < packet.data.length; i++)
			msg += lookup[packet.data[i]];
		this.swf.write(msg);
	}
	
	this.onconnect = function() { }
	this.onreceive = function(packet) { }
}
