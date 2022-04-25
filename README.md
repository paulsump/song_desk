# song_desk

- Plays backing and beat for some reggae, pop, soul and bossa nova songs.
- Uses sampled piano and double bass rather than MIDI.

## TODO UI

- volume mixer
- go to bar (need full ui?)  
- pick song from list
  //TODO PICK from SongNotifier.titles
- dark mode (save battery)
- mute voice
- button pause

# TODO logic

- map voice, instrument/volume
  
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
  Declaration Of Rights
  
- Repeats
-   Golden Lady
    O Mundo e um Moinho

# TODO easy
  
- check all todos e.g.
  //TODO TRiplets
  // TODO CALL audioPlayer.dispose()

# TODO Tricky

- or at least stop the timer!...
- don't stop when phone goes black. - find out what this is called eg. lock.
  audioplayer play "stayAwake"

# TODO Later

- Ultimately to create, arrange, transpose songs.
