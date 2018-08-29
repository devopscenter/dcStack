#!/usr/bin/env python3
"""Functions useful to all element classes."""

import sys
import argparse
from subprocess import Popen, PIPE, STDOUT, CalledProcessError
# ==============================================================================
__version__ = "0.1"

__copyright__ = "Copyright 2017, devops.center"
__credits__ = ["Bob Lozano", "Gregg Jensen"]
__license__ = ' \
   # Copyright 2014-2017 devops.center llc                                    \
   #                                                                          \
   # Licensed under the Apache License, Version 2.0 (the "License");          \
   # you may not use this file except in compliance with the License.         \
   # You may obtain a copy of the License at                                  \
   #                                                                          \
   #   http://www.apache.org/licenses/LICENSE-2.0                             \
   #                                                                          \
   # Unless required by applicable law or agreed to in writing, software      \
   # distributed under the License is distributed on an "AS IS" BASIS,        \
   # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. \
   # See the License for the specific language governing permissions and      \
   # limitations under the License.                                           \
   # '
__status__ = "Development"
# ==============================================================================


class ElementBase(object):
    """Serves base functionality for all element classes."""

    def __init__(self, nameIn, argList):
        """Constructor for the base class."""
        self.name = nameIn
#        if "CONFIG_FILE" in argList:
#            self.readConfigFile(argList["CONFIG_FILE"])
        if "APP_NAME" in argList:
            self.appName = argList["APP_NAME"]
        if "ORGANIZATION" in argList:
            self.profile = argList["ORGANIZATION"]
            self.organization = argList["ORGANIZATION"]
        if "REGION" in argList:
            self.region = argList["REGION"]
        if "ENV" in argList:
            self.env = argList["ENV"]
        if "SUFFIX" in argList:
            self.suffix = argList["SUFFIX"]
        if "STACK" in argList:
            self.stack = argList["STACK"]
        if "STACK_DIR" in argList:
            self.stackDir = argList["STACK_DIR"]
        if "PGVERSION" in argList:
            self.postgresVersion = argList["PGVERSION"]
        # print("ElementBase args: {}".format(argList))

#    def readConfigFile(self, theFileName):
#        """Read the config file for the key/value pairs listing the paths."""
#        # check to see if the config file exists
#        try:
#            tmpFileHandle = open(theFileName, 'r')
#            tmpFileHandle.close()
#        except IOError:
#            print("Unable to access the config file: {}".format(theFileName))
#            sys.exit(1)
#
#        self.config = ConfigParser()
#        self.config.read(theFileName)
#
#        for keyName, aValue in self.config.items("settings"):
#            if not hasattr(self, keyName):
#                setattr(self, keyName, aValue)

    def runScript(self, shellScript):
        """Execute the passed in shell script."""
        print(self.__class__.__name__ + " EXECUTING: " + shellScript)
        # NOTE: this is a python3
        with Popen(shellScript, shell=True, stdout=PIPE, bufsize=1,
                   universal_newlines=True) as p:
            for line in p.stdout:
                print(line, end='')  # process line here

        if p.returncode != 0:
            raise CalledProcessError(p.returncode, p.args)
            sys.exit(1)

    def priorToRun(self):
        """Execute steps prior to running."""
        return

    def postRunning(self):
        """Execute steps after the run has completed."""
        return


def checkArgs():
    """Check the command line arguments."""
    parser = argparse.ArgumentParser(
        description=('comment'))
    parser.parse_args()


def main(argv):
    """Main code goes here."""
    checkArgs()


if __name__ == "__main__":
    main(sys.argv[1:])

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
