#!/usr/bin/env python3
"""Docstring for module."""

import sys
import argparse
import os
from elementbase import ElementBase
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


class dcLogging(ElementBase):
    """Class to provide the necessary stuff for logging to syslog."""

    def __init__(self, argList):
        """Constructor for this class."""
        ElementBase.__init__(self, "logging", argList)
        self.executePath = self.stackDir + "/logging"
        self.executeScript = "./i-enable-logging.sh"

    def priorToRun(self):
        """Execute steps prior to running."""
        # run the deployenv script
        self.runDeployEnv()

    def postRunning(self):
        """Execute steps after the run has completed."""
        return

    def run(self):
        """Run the element to install the corresponding code."""
        # save the current directory
        currentDir = os.getcwd()
        theDir = os.path.expanduser(self.executePath)
        os.chdir(theDir)
        self.runScript(self.executeScript)

        # and move back to the original directory
        os.chdir(currentDir)

    def runDeployEnv(self):
        """Execute the deployEnv.sh script on the instance."""
        theDir = os.path.expanduser("~/dcUtils")

        self.runScript(theDir + "/deployenv.sh --type instance --env "
                       + self.env + " --appName " + self.appName)


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
