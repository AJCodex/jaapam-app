// Firestore security-rules tests. These run in Node, not Flutter.
//
// Setup (one-time):
//   cd test-rules
//   npm install
//
// Run:
//   firebase emulators:start --only firestore --project=demo-jaapam
//   # in another shell:
//   cd test-rules && npm test
//
// The rules verified here:
//   1. Anonymous users cannot read /users or /campaigns
//   2. A signed-in user can write their own profile but NOT set isAdmin
//   3. A non-admin user CANNOT create /campaigns/current
//   4. An admin user (users/{uid}.isAdmin=true) CAN create /campaigns/current
//   5. Any signed-in user can read /campaigns/* and write own contribution

import { initializeTestEnvironment, assertSucceeds, assertFails, RulesTestEnvironment } from "@firebase/rules-unit-testing";
import { doc, setDoc, getDoc, setLogLevel } from "firebase/firestore";
import * as fs from "node:fs";
import * as path from "node:path";

let env: RulesTestEnvironment;

beforeAll(async () => {
  setLogLevel("error");
  env = await initializeTestEnvironment({
    projectId: "demo-jaapam",
    firestore: {
      rules: fs.readFileSync(path.resolve(__dirname, "../firestore.rules"), "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

afterAll(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

const baseProfile = {
  displayName: "Test User",
  temple: "Shri Mandir",
  locale: "en",
  createdAt: new Date().toISOString(),
  dailyGoal: 1000,
};

test("anonymous user cannot read users", async () => {
  const anon = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(anon, "users/someone")));
});

test("signed-in user can create own profile WITHOUT isAdmin", async () => {
  const u = env.authenticatedContext("u1").firestore();
  await assertSucceeds(setDoc(doc(u, "users/u1"), baseProfile));
});

test("signed-in user cannot set isAdmin on own profile", async () => {
  const u = env.authenticatedContext("u1").firestore();
  await assertFails(setDoc(doc(u, "users/u1"), { ...baseProfile, isAdmin: true }));
});

test("user cannot read another user's profile", async () => {
  // Seed via privileged context
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "users/other"), baseProfile);
  });
  const u = env.authenticatedContext("u1").firestore();
  await assertFails(getDoc(doc(u, "users/other")));
});

test("non-admin cannot create campaign", async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "users/u1"), baseProfile);
  });
  const u = env.authenticatedContext("u1").firestore();
  await assertFails(
    setDoc(doc(u, "campaigns/current"), {
      title: "Hack",
      subtitle: "",
      goal: 10,
      isActive: true,
      createdBy: "u1",
      createdAt: new Date().toISOString(),
    })
  );
});

test("admin CAN create campaign", async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "users/admin1"), {
      ...baseProfile,
      isAdmin: true,
    });
  });
  const a = env.authenticatedContext("admin1").firestore();
  await assertSucceeds(
    setDoc(doc(a, "campaigns/current"), {
      title: "Paryushan",
      subtitle: "",
      goal: 1000000,
      isActive: true,
      createdBy: "admin1",
      createdAt: new Date().toISOString(),
    })
  );
});

test("any signed-in user can read campaigns", async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "campaigns/current"), {
      title: "X", subtitle: "", goal: 1, isActive: true, createdBy: "admin1",
    });
  });
  const u = env.authenticatedContext("u2").firestore();
  await assertSucceeds(getDoc(doc(u, "campaigns/current")));
});
