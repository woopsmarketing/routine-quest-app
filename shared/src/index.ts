/**
 * @fileoverview Shared utilities and types for Routine Quest App
 * @description Common constants, types, and utility functions used across client, API, and AI services
 */

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  timestamp: string;
}

// User related types
export interface User {
  id: string;
  email: string;
  tier: UserTier;
  timezone: string;
  pbtTime?: string; // Personal Boost Time (HH:MM format)
  streak: number;
  graceTokens: number;
  createdAt: string;
}

export enum UserTier {
  FREE = 'free',
  BASIC = 'basic', 
  PRO = 'pro',
  TEAM = 'team'
}

// Routine & Step types
export interface Routine {
  id: string;
  userId: string;
  title: string;
  isPublic: boolean;
  version: number;
  lastChangedAt: string;
  steps: Step[];
}

export interface Step {
  id: string;
  routineId: string;
  order: number;
  title: string;
  difficulty: number;
  estimatedSeconds: number;
  type: StepType;
}

export enum StepType {
  ACTION = 'action',
  TIMER = 'timer',
  CHECK = 'check',
  INPUT = 'input'
}

// Session & Progress types
export interface Session {
  id: string;
  userId: string;
  routineId: string;
  startedAt: string;
  finishedAt?: string;
  checkins: CheckIn[];
}

export interface CheckIn {
  id: string;
  sessionId: string;
  stepId: string;
  timeSpentSeconds: number;
  status: CheckInStatus;
  completedAt: string;
}

export enum CheckInStatus {
  COMPLETED = 'completed',
  SKIPPED = 'skipped',
  FAILED = 'failed'
}

// Gamification types
export interface Reward {
  id: string;
  userId: string;
  type: RewardType;
  payload: Record<string, any>;
  earnedAt: string;
}

export enum RewardType {
  XP = 'xp',
  STREAK_RING = 'streak_ring',
  SEASON_ITEM = 'season_item',
  ACHIEVEMENT = 'achievement'
}

// Constants
export const APP_CONFIG = {
  // XP & Scoring
  BASE_XP_PER_STEP: 10,
  PBT_BONUS_MULTIPLIER: 1.1, // +10% during Personal Boost Time
  STREAK_BONUS_MULTIPLIER: 1.05, // +5% per streak day (max 50%)
  MAX_STREAK_BONUS: 10, // Maximum 10 days for bonus calculation
  
  // Time windows
  PBT_WINDOW_MINUTES: 30, // ±30 minutes around PBT
  
  // Free tier limits
  FREE_TIER_ROUTINES: 1,
  FREE_TIER_STEPS_PER_ROUTINE: 5,
  FREE_TIER_HISTORY_DAYS: 3,
  
  // AI limits per tier
  AI_CREDITS: {
    [UserTier.FREE]: 0,
    [UserTier.BASIC]: 3,
    [UserTier.PRO]: 15,
    [UserTier.TEAM]: 50
  }
} as const;

// Utility functions
export const formatDuration = (seconds: number): string => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
};

export const calculateXP = (
  baseXP: number,
  isPBT: boolean = false,
  streakDays: number = 0
): number => {
  let xp = baseXP;
  
  // Apply PBT bonus
  if (isPBT) {
    xp *= APP_CONFIG.PBT_BONUS_MULTIPLIER;
  }
  
  // Apply streak bonus
  const streakBonus = Math.min(streakDays, APP_CONFIG.MAX_STREAK_BONUS) * 0.05;
  xp *= (1 + streakBonus);
  
  return Math.round(xp);
};

export const isWithinPBT = (
  userPBT: string, // "HH:MM" format
  currentTime: Date,
  timezoneOffset: number = 0
): boolean => {
  const [hours, minutes] = userPBT.split(':').map(Number);
  const pbtTime = new Date(currentTime);
  pbtTime.setHours(hours, minutes, 0, 0);
  
  // Apply timezone offset
  pbtTime.setMinutes(pbtTime.getMinutes() + timezoneOffset);
  
  const diffMinutes = Math.abs(currentTime.getTime() - pbtTime.getTime()) / (1000 * 60);
  return diffMinutes <= APP_CONFIG.PBT_WINDOW_MINUTES;
};

// Error types
export class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}

export class AuthError extends AppError {
  constructor(message: string = 'Authentication required') {
    super(message, 'AUTH_ERROR', 401);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string = 'Resource') {
    super(`${resource} not found`, 'NOT_FOUND', 404);
  }
}