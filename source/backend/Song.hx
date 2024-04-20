package backend;

import haxe.Json;
import lime.utils.Assets;

import backend.Section;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	@:optional var gameOverChar:String;
	@:optional var gameOverSound:String;
	@:optional var gameOverLoop:String;
	@:optional var gameOverEnd:String;
	
	@:optional var disableNoteRGB:Bool;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var gameOverChar:String;
	public var gameOverSound:String;
	public var gameOverLoop:String;
	public var gameOverEnd:String;
	public var disableNoteRGB:Bool = false;
	public var speed:Float = 1;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';

	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if(songJson.gfVersion == null) // Convert player3 to gfVersion
		{
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if(songJson.events == null) // Move any events from notes to events
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}

		for (i in 0...songJson.notes.length) { // Convert mustHitSections and gfSections to a camera event
			var prevSection = songJson.notes[i-1];
			var section = songJson.notes[i];
			if (section.mustHitSection != null && section.gfSection != null) {
				var gfSectionChanged = prevSection != null && section.gfSection != prevSection.gfSection;
				var mustHitSectionChanged = prevSection != null && !section.gfSection && section.mustHitSection != prevSection.mustHitSection;
				if (prevSection == null || gfSectionChanged || mustHitSectionChanged) {
					var addedToExisting = false;
					for (j in 0...songJson.events.length) {
						if (millisecondsApart(songJson.events[j][0], sectionStartTime(songJson, i))) {
							songJson.events[j][1].push(['Set Camera Position', section.gfSection ? 'gf' : section.mustHitSection ? 'bf' : 'dad', '']);
							addedToExisting = true;
						}
					}
					if (!addedToExisting)
						cast(songJson.events, Array<Dynamic>).push([sectionStartTime(songJson, i), [['Set Camera Position', section.gfSection ? 'gf' : section.mustHitSection ? 'bf' : 'dad', '']]]);
				}
				if (section.mustHitSection) {
					for (j in 0...section.sectionNotes.length)
						section.sectionNotes[j][1] = (section.sectionNotes[j][1] + 4) % 8;
				}

				if (section.gfSection) {
					var notes = cast(section.sectionNotes, Array<Dynamic>);
					for (j in 0...notes.length) {
						if (section.mustHitSection)
							if (notes[j][1] > 3) notes[j][3] = 'GF Sing';
						else
							if (notes[j][1] < 4) notes[j][3] = 'GF Sing';
					}
				}
			}
		}
		for (i in 0...songJson.notes.length) { // Remove mustHitSections and gfSections
			songJson.notes[i].mustHitSection = null;
			songJson.notes[i].gfSection = null;
		}
	}

	static function millisecondsApart(time1:Float, time2:Float):Bool {
		return time1 >= time2 - 1.5 && time1 <= time2 + 1.5;
	}

	static function sectionStartTime(song:Dynamic, section:Int = 0):Float {
		var daBPM:Float = song.bpm;
		var daPos:Float = 0;
		for (i in 0...section) {
			if (song.notes[i] != null) {
				if (song.notes[i].changeBPM)
					daBPM = song.notes[i].bpm;
				daPos += song.notes[i].sectionBeats > 0 ? song.notes[i].sectionBeats : 4 * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong);
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if(rawJson == null) {
			var path:String = Paths.json(formattedFolder + '/' + formattedSong);

			#if sys
			if(FileSystem.exists(path))
				rawJson = File.getContent(path).trim();
			else
			#end
				rawJson = Assets.getText(Paths.json(formattedFolder + '/' + formattedSong)).trim();
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		var songJson:Dynamic = parseJSONshit(rawJson);
		if(jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		return cast Json.parse(rawJson).song;
	}
}
