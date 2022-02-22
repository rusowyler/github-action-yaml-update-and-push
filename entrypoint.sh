#!/bin/sh -l

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

echo "[+] Action start"
YQ_VERSION="${1}"
YAML_FILE="${2}"
YAML_PATH="${3}"
YAML_VALUE="${4}"
USER_EMAIL="${5}"
USER_NAME="${6}"
GITHUB_SERVER="${7}"
REPOSITORY_USERNAME="${8}"
REPOSITORY_NAME="${9}"
TARGET_BRANCH="${10}"
COMMIT_MESSAGE="${11}"

ORIGIN_COMMIT="https://$GITHUB_SERVER/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"
COMMIT_MESSAGE="${COMMIT_MESSAGE/\$GITHUB_REF/$GITHUB_REF}"
COMMIT_MESSAGE="${COMMIT_MESSAGE/YAML_FILE/$YAML_FILE}"
COMMIT_MESSAGE="${COMMIT_MESSAGE/YAML_PATH/$YAML_PATH}"
COMMIT_MESSAGE="${COMMIT_MESSAGE/YAML_VALUE/$YAML_VALUE}"

# Make sure we have a version:
echo "[+] Downloding yq $YQ_VERSION version"
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq && \
chmod +x /usr/bin/yq

if [ -z "$USER_NAME" ]; then
    USER_NAME="$REPOSITORY_USERNAME"
fi

CLONE_DIR=$(mktemp -d)

echo "[+] Cloning destination git repository $REPOSITORY_NAME"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"

{
    git clone --single-branch --branch "$TARGET_BRANCH" "https://$USER_NAME:$API_TOKEN_GITHUB@$GITHUB_SERVER/$REPOSITORY_USERNAME/$REPOSITORY_NAME.git" "$CLONE_DIR"
    } || {
    echo "::error::Could not clone the destination repository. Command:"
    echo "::error::git clone --single-branch --branch $TARGET_BRANCH https://$USER_NAME:the_api_token@$GITHUB_SERVER/$REPOSITORY_USERNAME/$REPOSITORY_NAME.git $CLONE_DIR"
    echo "::error::(Note that the USER_NAME and API_TOKEN is redacted by GitHub)"
    echo "::error::Please verify that the target repository exist AND that it contains the destination branch name, and is accesible by the API_TOKEN_GITHUB"
    exit 1
}

echo "[+] cd into $CLONE_DIR"
cd $CLONE_DIR

if [ ! -f "$CLONE_DIR/$YAML_FILE" ]; then
    ls -a $CLONE_DIR/
    echo "::error::Requested file doesn't exist: $CLONE_DIR/$YAML_FILE"
    exit 1
fi

echo "[+] Running YQ"
echo "- Doing: $YAML_PATH = strenv(YAML_VALUE)"
echo "- To: $CLONE_DIR/$YAML_FILE"
echo "- Where value is: $YAML_VALUE"

VALUE=$YAML_VALUE /usr/bin/yq -i "$YAML_PATH = strenv(VALUE)" $CLONE_DIR/$YAML_FILE || {
    echo "::error::YQ failed executing $YAML_PATH = strenv(YAML_VALUE)"
    exit 1
}

echo "Result:"
cat $CLONE_DIR/$YAML_FILE

echo "[+] Adding git commit"
git add .

echo "[+] git status:"
git status

echo "[+] git diff-index:"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "[+] Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push "https://$USER_NAME:${API_TOKEN_GITHUB}@$GITHUB_SERVER/$REPOSITORY_USERNAME/$REPOSITORY_NAME.git" --set-upstream "$TARGET_BRANCH"
