set -e
remote=origin
if [[ $PRODUCTION ]]; then
  echo "Deploy to production? (y/n)"
  read ans
  if [[ $ans == "y" ]]; then
    remote="origin"
  fi
fi
diffs=`git diff --name-status HEAD`
if [[ "" != $diffs ]]; then
 echo "Can't deploy, unsaved changes:"
 echo $diffs
 exit
fi
git checkout -b gh-pages
npm install
echo "Starting build"
node build.js
echo "Build complete"
rm -rf `ls -d * | grep -vP 'site' | xargs`
echo "Cleaned out directory:"
mv site/* .
echo "Copied out"
if [[ $BUILD_ONLY ]]; then
  exit
fi
rm -rf site
git log -1
git add . -A
git commit -m 'latest'
echo "Commit created: $(ls)"
git log -1
echo "pushing to ${GH_REG}"
git push --force --quiet https://${github_token}@${GH_REF} gh-pages > /dev/null 2>&1
echo "Deployed to $remote"
