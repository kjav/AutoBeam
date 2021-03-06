//=============================================================================
//  AutoBeam
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation.
//=============================================================================

import QtQuick 2.0
import MuseScore 1.0

MuseScore {
  version:  "1.0"
  description: "This plugin sets the beam mode of all selected notes to 'automatic'."
  menuPath: "Plugins.AutoBeam"

  // Apply the given function to all notes in selection
  // or, if nothing is selected, in the entire score

  function applyToNotesInSelection() {
    var cursor = curScore.newCursor();
    cursor.rewind(1);
    var startStaff;
    var endStaff;
    var endTick;
    var fullScore = false;
    if (!cursor.segment) { // no selection
      fullScore = true;
      startStaff = 0; // start with 1st staff
      endStaff = curScore.nstaves - 1; // and end with last
    } else {
      startStaff = cursor.staffIdx;
      cursor.rewind(2);
      if (cursor.tick == 0) {
        // this happens when the selection includes
        // the last measure of the score.
        // rewind(2) goes behind the last segment (where
        // there's none) and sets tick=0
        endTick = curScore.lastSegment.tick + 1;
      } else {
        endTick = cursor.tick;
      }
      endStaff = cursor.staffIdx;
    }
    for (var staff = startStaff; staff <= endStaff; staff++) {
       for (var voice = 0; voice < 4; voice++) {
         cursor.rewind(1); // sets voice to 0
         cursor.voice = voice; //voice has to be set after goTo
         cursor.staffIdx = staff;

         if (fullScore)
           cursor.rewind(0) // if no selection, beginning of score

         while (cursor.segment && (fullScore || cursor.tick < endTick)) {
           if (cursor.element && cursor.element.type == Element.CHORD)
             cursor.element.beamMode = 0;
           cursor.next();
         }
       }
     }
  }

  onRun: {
    if (typeof curScore === 'undefined')
    Qt.quit();

    applyToNotesInSelection()

    Qt.quit();
  }
}
