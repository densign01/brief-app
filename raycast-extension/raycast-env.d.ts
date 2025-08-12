/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {
  /** Email Address - Email address to send articles to */
  "email": string,
  /** API Endpoint - Brief API endpoint */
  "apiEndpoint": string,
  /** Enable AI Summary by Default - Generate AI summaries by default */
  "defaultAiSummary": boolean,
  /** Default Summary Length - Default length for AI summaries */
  "summaryLength": "short" | "long"
}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `capture-article` command */
  export type CaptureArticle = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `capture-article` command */
  export type CaptureArticle = {}
}

