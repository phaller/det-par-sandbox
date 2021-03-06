#!/usr/bin/env bash
# https://gist.github.com/1643715
# This is very hacky remedy to following error people using sbt
# and 2.10.0-M1 release of Scala are going to see:
#
# API.scala:261: error: type mismatch;
# found : API.this.global.tpnme.NameType
# (which expands to) API.this.global.TypeName
# required: String
# sym.isLocalClass || sym.isAnonymousClass || sym.fullName.endsWith(LocalChild)
#
# This script fixes sbt's compiler interface so error presented above disappears.
# I believe it should be fairly safe to use because sbt ships binary
# interfaces for 2.9.x compiler so this patch wouldn't affect them.
# Author: Grzegorz Kossakowski <grzegorz.kossakowski@gmail.com>

set -e

PATCH=$(cat <<EOF
--- API.scala.orig 2011-10-19 21:25:46.000000000 +0200
+++ API.scala 2012-01-19 23:57:23.000000000 +0100
@@ -260,7 +260,7 @@
None
}
private def ignoreClass(sym: Symbol): Boolean =
- sym.isLocalClass || sym.isAnonymousClass || sym.fullName.endsWith(LocalChild)
+ sym.isLocalClass || sym.isAnonymousClass || sym.fullName.endsWith(LocalChild.toString)
// This filters private[this] vals/vars that were not in the original source.
// The getter will be used for processing instead.
EOF
)

for i in $(find $HOME/.sbt/boot/scala-2.9.1/org.scala-tools.sbt/sbt/0.11.*/compiler-interface-src -name 'compiler-interface-src-0.11.*.jar'); do
t="${i%.jar}-tmp"
  echo $t
  unzip $i -d $t
  cd $t
  #apply the patch only if it's not applied yet
  (set +e; grep -q 'sym\.isLocalClass || sym\.isAnonymousClass || sym\.fullName\.endsWith(LocalChild\.toString)' API.scala;
    if [ "$?" -ne 0 ]; then patch <<< "$PATCH"; fi; set -e)
  rm $i
  zip -r $i .
  cd ..
  rm -rf $t
done