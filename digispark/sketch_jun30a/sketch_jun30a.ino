#include "DigiKeyboard.h"
#define DELAY 500
void loop() {}
void setup() {              
  pinMode(1, OUTPUT);
  digitalWrite(1, HIGH);
  DigiKeyboard.sendKeyStroke(0);
  DigiKeyboard.delay(2500);
  DigiKeyboard.delay(DELAY);

  DigiKeyboard.println("""pragma solidity >=0.4.22 <0.7.0;""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""contract BallotTest {""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""\t\tbytes32[] proposalNames;""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""\t\tBallot ballotToTest;""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""\t\tfunction beforeAll () public {""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""\t\t\t\tproposalNames.push(bytes32(\"candidate1\"));""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""\t\t\t\tballotToTest = new Ballot(proposalNames);""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""\t\t}""");
  DigiKeyboard.delay(DELAY);
  DigiKeyboard.println("""}""");
  DigiKeyboard.delay(DELAY);
}
