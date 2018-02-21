#!/usr/bin/env python
"""Builder of instances."""

import sys
import os
import argparse
# from process_dc_env import pythonGetEnv, dcEnvCheckArgs
from base import Base
from python import Python
from logging import Logging
from supervisor import Supervisor
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


class InstanceBuilder:
    """Builder of instances."""

    def __init__(self, argsDict, testMode):
        """Constructor for the InstanceBuilder."""
        self.test = testMode
        self.argList = argsDict
        self.elementsToInclude = argsDict["ELEMENTS_TO_INCLUDE"]

    def buildIt(self):
        """Execute the build based upon the elements."""
        # first setup some standardized directories
        self.setupStandardDirectories()

        for element in self.elementsToInclude:
            elementClassName = element[:1].upper() + element[1:]
            aClassName = globals()[elementClassName]
            theElement = aClassName(self.argList)
            theElement.run()

    def setupStandardDirectories(self):
        """Create the standard set of directories."""
        # get the uid and gid for root for chown later
        uid = int(os.environ.get('SUDO_UID'))
        gid = int(os.environ.get('SUDO_GID'))

        # first make the /data directory
        dataDir = "/data"
        if not os.path.exists(dataDir):
            os.makedirs(dataDir, 0o755)

        # ----------------------------------------------------------------------
        # If this will have an attached scratch volume, then prepare and mount
        # it, then make sure that code deploys go onto the scratch volume as
        # well.
        # ----------------------------------------------------------------------
        deployDir = "/data/deploy"
        if "SCRATCHVOLUME" in self.elementsToInclude:
            # hold the original directory
            originalDir = os.getcwd()
            # and change the dcStack postgres directory so that we can run the
            # mount script
            destDir = os.path.expanduser("~/dcStack/db/postgres")
            os.chdir(destDir)
            # TODO callexternal process i-mount.sh "/media/data"
#             sudo . / i - mount.sh "/media/data"

            # now we need to make the deploy directory and then set up
            # a symbolic link for legacy reasons
            mediaDeployDir = "/media/data/deploy"
            deployDir = "/data/deploy"
            if not os.path.exists(mediaDeployDir):
                os.makedirs(mediaDeployDir, 0o755)
                os.symlink(mediaDeployDir, deployDir)
                os.chown(mediaDeployDir, uid, gid)
                os.chown(deployDir, uid, gid)

                # and now go back to the original directory to proceed
                # with processing
                os.chdir(originalDir)
        else:
            os.makedirs(deployDir, 0o755)
            os.chown(deployDir, uid, gid)

        # Create standard temp directory, then set up a symlink
        # to a previous standard, for compatibility reasons
        # Also create a standard directory for db restores.
        # sudo mkdir - p / media / data / tmp
        mediaTmpDir = "/media/data/tmp"
        scratchDir = "/data/scratch"
        if not os.path.exists(mediaTmpDir):
            os.makedirs(mediaTmpDir, 0o777)
            os.symlink(mediaTmpDir, scratchDir)
            os.chown(mediaTmpDir, uid, gid)
            os.chown(scratchDir, uid, gid)

        # and now make the db_restore directory
        mediaDBRestoreDir = "/media/data/db_restore"
        if not os.path.exists(mediaDBRestoreDir):
            os.makedirs(mediaDBRestoreDir, 0o777)
            os.chown(mediaDBRestoreDir, uid, gid)


def checkArgs():
    """Check the command line arguments."""
    parser = argparse.ArgumentParser(
        description=('comment'))
    parser.add_argument('-i', '--elementsToInclude', help='The list of '
                        'elements names that will correspond to the '
                        'modules to be added to the instance.',
                        required=True)
    parser.add_argument('-c', '--configFile', help='Config file that '
                        'holds variables that define paths on the local'
                        'system.',
                        required=False)
    parser.add_argument('-p', '--profile',
                        help='This is the AWS profile that needs to be used.',
                        required=True)
    parser.add_argument('-r', '--region',
                        help='This is the AWS profile that needs to be used.',
                        required=False)
    parser.add_argument('--suffix',
                        help='This is the defined suffix for this instance.',
                        required=False)
    parser.add_argument('--stack',
                        help='This is the name of the stack to use.',
                        required=False)
    parser.add_argument('--stackDir',
                        help='This is the path to where the stack is.',
                        required=False)
    parser.add_argument('-t', '--test', help='Will run the script but '
                        'will not actually execute the shell commands.'
                        'Think of this as a dry run or a run to be used'
                        ' with a testing suite',
                        action="store_true",
                        required=False)
    args, unknown = parser.parse_known_args()

    retArgs = {}

    if args.elementsToInclude:
        retElements = [x.strip() for x in args.elementsToInclude.split(',')]
        retArgs["ELEMENTS_TO_INCLUDE"] = retElements

    if args.configFile:
        retArgs["CONFIG_FILE"] = args.configFile

    if args.profile:
        retArgs["PROFILE"] = args.profile

    if args.region:
        retArgs["REGION"] = args.region

    if args.suffix:
        retArgs["SUFFIX"] = args.suffix

    if args.stack:
        retArgs["STACK"] = args.suffix

    if args.stackDir:
        retArgs["STACK_DIR"] = args.suffix

    retTest = ""
    if args.test:
        retTest = args.test

    return (retArgs, retTest)


def main(argv):
    """Main code goes here."""
    try:
        (cmdLineArgs, testMode) = checkArgs()
    except SystemExit:
        # dcEnvCheckArgs()
        print("Some arguments provided are not supported")
        sys.exit(1)

        # get the list of key/value pairs from the app-utils
        # envList = pythonGetEnv()

        # take the key/value arguments from the command line
        # and create one list of a merged set of key/value pairs
        # from the environment and from the command line
    argsList = cmdLineArgs.copy()
    # argsList.update(envList)

    # and then use that combined list to create an instance of
    # an InstanceBuilder to create the needed instance
    aBuilder = InstanceBuilder(argsList, testMode)

    aBuilder.buildIt()


if __name__ == "__main__":
    main(sys.argv[1:])

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
