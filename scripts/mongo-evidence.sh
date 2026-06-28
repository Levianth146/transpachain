#!/usr/bin/env bash
# TranspaChain MongoDB evidence — one-shot stats for docs/screenshots.
#
# Usage (EC2 production):
#   cd /path/to/transpachain
#   ./scripts/mongo-evidence.sh
#   COMPOSE_FILE=docker-compose.prod.yml ./scripts/mongo-evidence.sh
#
# Usage (local dev):
#   ./scripts/mongo-evidence.sh
#   COMPOSE_FILE=docker-compose.yml ./scripts/mongo-evidence.sh
#
# Direct container (no compose):
#   MONGO_CONTAINER=transpachain-mongo ./scripts/mongo-evidence.sh
#
# Override database:
#   MONGO_DB=transpachain ./scripts/mongo-evidence.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

COMPOSE_FILE="${COMPOSE_FILE:-}"
if [[ -z "${COMPOSE_FILE}" ]]; then
  if [[ -f "${REPO_ROOT}/docker-compose.prod.yml" ]] \
    && docker compose -f "${REPO_ROOT}/docker-compose.prod.yml" ps --status running "${MONGO_SERVICE:-mongodb}" 2>/dev/null | grep -q mongodb; then
    COMPOSE_FILE="docker-compose.prod.yml"
  else
    COMPOSE_FILE="docker-compose.yml"
  fi
fi

MONGO_SERVICE="${MONGO_SERVICE:-mongodb}"
MONGO_DB="${MONGO_DB:-transpachain}"
MONGO_CONTAINER="${MONGO_CONTAINER:-}"

run_mongosh() {
  if [[ -n "${MONGO_CONTAINER}" ]]; then
    docker exec -i "${MONGO_CONTAINER}" mongosh --quiet "${MONGO_DB}"
  else
    docker compose -f "${REPO_ROOT}/${COMPOSE_FILE}" exec -T "${MONGO_SERVICE}" \
      mongosh --quiet "${MONGO_DB}"
  fi
}

cd "${REPO_ROOT}"

MONGO_DB="${MONGO_DB}" run_mongosh <<EOF
const DB_NAME = "${MONGO_DB}";

const SENSITIVE_KEYS = new Set([
  "contactEmail",
  "reviewerNote",
  "closedReason",
  "__v",
]);

const MAX_STR_LEN = 80;
const MAX_DESC_LEN = 120;

function redactValue(key, value) {
  if (value === null || value === undefined) return value;
  if (SENSITIVE_KEYS.has(key)) return "[REDACTED]";
  if (typeof value === "string") {
    const limit = key === "description" ? MAX_DESC_LEN : MAX_STR_LEN;
    if (value.length > limit) {
      return value.slice(0, limit) + "… (" + value.length + " chars)";
    }
    return value;
  }
  if (value instanceof Date) return value.toISOString();
  if (Array.isArray(value)) {
    return value.map((item, i) => redactValue(String(i), item));
  }
  if (typeof value === "object") return redactDoc(value);
  return value;
}

function redactDoc(doc) {
  const out = {};
  for (const [key, value] of Object.entries(doc)) {
    if (key === "_id") {
      out._id = String(value);
      continue;
    }
    out[key] = redactValue(key, value);
  }
  return out;
}

function bannerLine(ch) {
  return ch.repeat(40);
}

const now = new Date().toISOString();
print(bannerLine("="));
print(" TranspaChain MongoDB Evidence");
print(" " + now);
print(" Database: " + DB_NAME);
print(bannerLine("="));

const dbRef = db.getSiblingDB(DB_NAME);

const knownCollections = [
  "campaigns",
  "donations",
  "proposals",
  "verifiedorgs",
  "orgprofiles",
  "evidence",
  "orgreconcilestates",
];

const existing = dbRef.getCollectionNames().sort();
const allCollections = [...new Set([...knownCollections, ...existing])].sort();

print("");
print("Collections:");
for (const name of allCollections) {
  if (!existing.includes(name)) {
    print("  " + name.padEnd(20) + " : (missing)");
    continue;
  }
  const count = dbRef.getCollection(name).countDocuments();
  print("  " + name.padEnd(20) + " : " + count);
}

const sampleCollections = [
  "campaigns",
  "donations",
  "proposals",
  "verifiedorgs",
  "orgprofiles",
  "evidence",
];

print("");
print("Indexes (main collections):");
for (const name of sampleCollections) {
  if (!existing.includes(name)) continue;
  const indexes = dbRef.getCollection(name).getIndexes();
  print("  " + name + ":");
  indexes.forEach((idx) => {
    const keys = Object.entries(idx.key)
      .map(([k, v]) => k + ":" + v)
      .join(", ");
    const unique = idx.unique ? " [unique]" : "";
    print("    - " + idx.name + " ({ " + keys + " })" + unique);
  });
}

print("");
for (const name of sampleCollections) {
  if (!existing.includes(name)) continue;
  const doc = dbRef.getCollection(name).findOne({}, { sort: { _id: -1 } });
  const label = name === "orgprofiles" ? "organization (orgprofile)" : name.slice(0, -1);
  print("Sample " + label + ":");
  if (!doc) {
    print("  (empty collection)");
  } else {
    print("  " + JSON.stringify(redactDoc(doc), null, 2).split("\n").join("\n  "));
  }
  print("");
}

const stats = dbRef.stats();
print("Database stats:");
print("  collections : " + stats.collections);
print("  objects     : " + stats.objects);
print("  dataSize    : " + stats.dataSize + " bytes");
print("  storageSize : " + stats.storageSize + " bytes");
print("  indexes     : " + stats.indexes);
print(bannerLine("="));
EOF
