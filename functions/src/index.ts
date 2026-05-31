/**
 * Jaapam Cloud Functions entry point.
 *
 * Phase 0: placeholder. Real functions (jaap aggregator, notifications,
 * moderation, leaderboard) land in later phases per docs/01-architecture.md.
 */
import {onRequest} from "firebase-functions/v2/https";
import {initializeApp} from "firebase-admin/app";

initializeApp();

export const health = onRequest({region: "asia-south1"}, (_req, res) => {
  res.status(200).json({status: "ok", service: "jaapam-functions"});
});
