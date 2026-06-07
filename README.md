
# TUNNELER BUT IT SUCKS
This is the rojo project for TUNNELER But It Sucks. I'm not bothered to explain how to use rojo, but there is plenty of resources that already exist that you can find. If you don't care about rojo, please just download the `tbis.rbxl` file. 

## VERY IMPORTANT NOTE
The main branch is the 0.4.1a version of the game. PLEASE SWITCH TO THE 0.5a BRANCH TO GET THE LATEST VERSION AND THE .rbxl FILE.
Also if you want me to help with stuff such as music, voicelines, sound effects or just explaining how some of the more confusing parts of the code works, please feel free to contact me on discord!

## ANOTHER VERY IMPORTANT NOTE
There are still very important things that should be done before any new content for TBIS is made, the most important stuff is listed in the `TODO.txt` file, the rest of the stuff can be found at the end of the changelog: https://docs.google.com/document/d/1lgMVHR7dQ1ZbiF0X6ucRr0AacR_I5HbsLfnOpb04MJk/edit?tab=t.0#heading=h.gmujuee88kl
If you aren't bothered to do this or don't know how to code, I'd suggest seeing if anyone else has done this and use what they've done to build off of. If you HAVE done this, please share it with others (and me so i can maybe link it here). On a similar note, I would rather have all TBIS mods to also be open source, but I won't really care too much if their not.

## SOUNDS, MUSIC AND VOICELINES
Because of the update that makes sounds not public, you will have to manually re-upload all the sounds yourself. All the sounds used in TBIS can be found in this google drive: https://drive.google.com/drive/folders/1-s73htZ0Uc0fDmyXsymwzA-uZRw2qeFc?usp=sharing
To add all the sounds to the game, the first step is to upload them all to Roblox. Since there are a lot of sounds, I would recommend using the bulk import feature found in the Asset Manager window in Roblox Studio, however you may have to rename a few sounds as Roblox's moderation is dumb. 
To actually put the sounds in the game, you will first want to find `Sounds.luau` which is located at `src\ReplicatedStorage\Data\Sounds.luau`. This script contains all the songs and sound effects found in TBIS. The contents of this script should look something like this:
```lua
return {
	Music = {
		-- songs here
	},
	SoundEffects = {
		-- sound effects here
	}
}
```
Each song has a definition that should look something like this:
```lua
["ExampleSong"] = {
	DisplayName = "Example Soundtack",
	NormalId = "rbxassetid://something",
	HighVelocityId = "rbxassetid://wevburidspbyveowipxn",
	HighAlertId = "rbxassetid://67",
	VolumeMultiplier = 2
}
```
The text in the square brackets is the name of the song that the game will use internally, for example, this is the name you have to use when playing the song through dev-console commands or through AudioService (AudioService is a custom service I made for TBIS; it is not found in normal Roblox). The DisplayName property is the name that gets shown in the Music section of the Extras menu. The NormalId, HighVelocityId and HighAlertId are where you put the sound IDs for the normal, high velocity and high alert versions of the song. Lastly, VolumeMultiplier is how much the volume of the sound effect will be multiplied by, for example, if VolumeMultiplier is 2, the song would be twice as loud, but if it was 0.5, it would be half as loud. The DisplayName, HighVelocityId, HighAlertId and VolumeMultiplier properties are all optional. If there is no DisplayName specified, it will just use the name in the square brackets. If there is no HighVelocityId or HighAlertId, then there just won't be any dynamic music for that soundtrack. If no VolumeMultiplier is specified, then the song will just play at its normal volume. This would also be the same as having VolumeMultiplier set to 1.
For the sound effects, each sound effect is defined like this:
```lua
ExampleSoundEffect = {
	SoundId = "rbxassetid://oj dev is very cool",
	VolumeMultiplier = 0.7
}
```
"ExampleSoundEffect" is the name of the sound effect, but unlike the songs, it isn't in square brackets (Why? I don't know). SoundId is, believe it or not, the ID of the sound for the sound effect, and VolumeMultiplier works the same way that it does for the songs. 

Adding the voicelines to TBIS is a very similar proccess to the music and sound effects. Firstly locate the `Voicelines.luau` file located at `src\ReplicatedStorage\Data\Voicelines.luau`. The voicelines in `Voicelines.luau` are catagorized by character, so there should be a catagory for the announcer's voicelines and another for Axis's voicelines. Each voiceline definiton should look something like this:
```lua
ExampleVoiceline = {
	Subtitle = "Hi i am a voiceline",
	SoundId = "rbxassetid://h",
	Emotion = "Happy" -- only for axis voicelines
},
```
 The way the voicelines are defined are very similar to the sound effects and music with the exeption of the new "Subtitle" property. The Subtitle proptery is the subtitle that is shown if the player has the "Subtitles" setting enabled. 
 The voicelines for Axis also have their own property, that being the "Emotion" property. This defines which emotion axis will have when he plays that voiceline. Axis's emotions include Game, Happy, Nervous, Neutral, Sad, Shocked, VeryHappy and Wink.

That should be everything you need to know to get sounds working in TBIS!

## I DO NOT KNOW HOW TO MANAGE A PUBLIC GITHUB REPOSITORY!!!
Please do not try to contribute to this repository as I do not know how to, and do not care to manage this stuff. If you actually know how to manage a github repository, please feel free to fork this and make some kind of TBIS community edition.
