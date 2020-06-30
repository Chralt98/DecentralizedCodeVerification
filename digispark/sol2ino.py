boilerplate_code_start = """
#include "DigiKeyboard.h"
#define DELAY 500
void loop() {}
void setup() {              
\tpinMode(1, OUTPUT);
\tdigitalWrite(1, HIGH);
\tDigiKeyboard.sendKeyStroke(0);
\tDigiKeyboard.delay(2500);
\tDigiKeyboard.delay(DELAY);
"""

boilerplate_code_end = "}"


def decide(line):
    println(line)
    delay()


def delay():
    print("\tDigiKeyboard.delay(DELAY);")


def println(line):
    print("\tDigiKeyboard.println(\"\"\"" + str(line).replace('  ', '\\t').replace('\"', '\\"') + "\"\"\");")


with open('input.sol', 'r') as file:
    print(boilerplate_code_start)
    lines = file.read().split('\n')
    for line in lines:
        decide(line)
    print(boilerplate_code_end)
