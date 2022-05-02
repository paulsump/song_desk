# "Song Desk"

- Plays backing and beat for some reggae, pop, soul and bossa nova songs.  
- Uses sampled piano and double bass rather than MIDI.  

## TODO 

### UI

- volume mixer
- go to bar (need full ui or just hack move time half way forward?)
  would be nice to scrub
- button pause  

### Logic bugs

fix duration bug  
  /// TODO removing this wantStartPlay fixes the tests  

### Logic

-  fix countIn

octave bass
- arp come in and out randomly (on, off, long or short duration)
  
- honour STEADY  
  Back to Black  

- count in from start instead because of play, playNext
  
- play bass of endChord  

- no: Create audioPlayer in getPlayer(), but then event would need to dispose()  

- alternate between soft and hard bass iff the same note.
- use soft for arp, mid for backing, and hard piano for vocal.
- alternate between soft, mid, and hard piano.  

- fix calcDuration bleed for  
  People Make The World Go Round  
  It Must Be Love (verse)  

- fix Don't Make Me Over at the end of verse weirdness.
- fix over plays note duration for bass  
  Addicted (ok with pitch=pitch and return null)  
  After All (p== p fixes the repeated notes, but breaks for when diff notes).  
  Life In The Ghetto  
  Love Me Forever  
  Melancolia  
  The Tide Is High  
  People Make The World Go Round
- My Conversation more swingy   

- fix bass missing notes  
  Life In The Ghetto  
  
- fade out (for piano) with audioPlayer.setVolume(0.5)  
  Silly Games  
  Golden Lady  

- Repeats  
  want to alter time somehow - simpler and would work for visual too.  
  scheduler takes off time in update if hit repeat  
    Golden Lady   
    O Mundo e um Moinho   
  Silly Games  (needs Endings too)  

setVolume is done on instrument's samples, which will be overwritten if i add a voice mixer  

### Easy

- check all todos e.g.  
  // TODO CALL audioPlayer.dispose()  

### Tricky

- or at least stop the timer!...  
- don't stop when phone goes black. - find out what this is called eg. lock.  
  audioplayer play "stayAwake"  

### Later

- Ultimately to create, arrange, transpose songs.  

### Maybe

- volume mixer vs volume encapsulation?  
  I need to have a factor to take the  
  perceived sample loudness out of the equation.  
  //TODO initialize from mixer volume here  
  double get volumeFactor // used in setVolume  

- map voice, instrument/volume
  // TODO MAYBE Map voices to player functions  
  // final _playerFuns = <String, dynamic>{};  

- hats
