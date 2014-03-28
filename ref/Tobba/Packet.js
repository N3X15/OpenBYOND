DM.Packet = function(id, length) {
	this.id = id;
	this.data = new Uint8Array(length);
	this.cursor = 0;

	this.Decode = function(key) {
		if (this.data.length == 0)
			return false;

		var check = this.data[this.data.length-1];
		this.data = this.data.subarray(0, this.data.length-1); // FIXME: this might be a bad idea
		if (this.data.length > 0)
		{
			var a = 0;

			for (var i = 0; i < this.data.length; i++)
			{
				this.data[i] -= (key >> (a & 0x1F)) + a;
				a = (a + this.data[i]) & 0xFF;
			}

			return a == check;
		}

		return true;
	}
	
	this.Encode = function(key) {
		var newdata = new Uint8Array(this.data.length+1);
		var a = 0;
		for (var i = 0; i < this.data.length; i++)
		{
			newdata[i] = this.data[i] + ((key >> (a & 0x1F)) + a);
			a = (a + this.data[i]) & 0xFF;
		}
		newdata[this.data.length] = a;
		this.data = newdata;
	}
	
	
	this.ReadByte = function() {
		return this.data[this.cursor++];
	}
	
	this.ReadShort = function() {
		return this.data[this.cursor++] + this.data[this.cursor++] * 0x100;
	}
	
	this.ReadLong = function() {
		return this.data[this.cursor++] + this.data[this.cursor++] * 0x100 + this.data[this.cursor++] * 0x10000 + this.data[this.cursor++] * 0x1000000;
	}
	
	this.ReadString = function() {
		var str = "";
		while (this.data[this.cursor] != 0) str += String.fromCharCode(this.data[this.cursor++]);
		this.cursor++;
		return str;
	}
	
	
	this.WriteByte = function(v) {
		this.data[this.cursor++] = v;
	}
	
	this.WriteShort = function(v) {
		this.data[this.cursor++] = v;
		this.data[this.cursor++] = v >> 8;
	}
	
	this.WriteLong = function(v) {
		this.data[this.cursor++] = v;
		this.data[this.cursor++] = v >> 8;
		this.data[this.cursor++] = v >> 16;
		this.data[this.cursor++] = v >> 24;
	}
	
	this.WriteString = function(str) {
		for (var i = 0; i < str.length; i++)
			this.data[this.cursor++] = str.charCodeAt(i);
		this.data[this.cursor++] = 0;
	}
}

DM.Packets = {}
DM.Packets.Version = function(version, netversion, key, sequence) {
	var packet = new DM.Packet(1, 14);
	packet.WriteLong(version)
	packet.WriteLong(netversion)
	key = key - ((netversion << 16) + version);
	if (key < 0)
		key += 0x100000000;
	packet.WriteLong(key);
	packet.WriteShort(sequence);
	return packet;
}

DM.Packets.Key = function() {
	// not a CLUE what most of the following means, its a sniffed decoded guest login, seems to be valid forever? static bullshite computerid on it though
	var d = [0, 0, 126, 204, 90, 46, 137, 53, 115, 215, 109, 151, 108, 181, 246, 0, 198, 4, 21, 43, 127, 61, 72, 1, 63, 255, 143, 90, 254, 145, 233, 209, 214, 23, 98, 0, 172, 46, 123, 99, 255, 26, 0, 0, 0, 0, 0];
	var packet = new DM.Packet(26, d.length);
	for (var i = 0; i < d.length; i++)
		packet.data[i] = d[i]
	return packet;
	
	/*var d = [0, 0, 126, 204, 90, 46, 137, 53, 115, 215, 109, 151, 108, 181, 246, 0, 198, 4, 21, 43, 127];
	var key = new Array(16);
	for (var i = 0; i < 16; i++)
		key[i] = Math.floor(Math.random()*255);
	var check = DM.CRC32('Guest'+key.map(function(v) { return ('00'+v.toString(16)).substr(-2); }).join(''));
	console.log(check);
	
	var packet = new DM.Packet(26, 47);
	for (var i = 0; i < d.length; i++)
		packet.WriteByte(d[i]);
	for (var i = 0; i < 16; i++)
		packet.WriteByte(key[i]);
	packet.WriteLong(check);
	packet.WriteByte(26); // 22 on non-guest logins
	packet.WriteLong(0);
	packet.WriteByte(0);*/
}

DM.Packets.ContinueDownload = function(hash, sequence) {
	var packet = new DM.Packet(159, 13);
	packet.WriteLong(hash);
	packet.WriteLong(0xFFFFFFFF);
	packet.WriteByte(0);
	packet.WriteLong(sequence); // seems to be some kinda sequence number?
	return packet;
}

DM.Packets.Topic = function(topic) {
	var packet = new DM.Packet(129, topic.length+1);
	packet.WriteString(topic);
	return packet;
}

