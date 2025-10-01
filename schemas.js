// File: backend/models/schemas.js
// How to name: backend/models/schemas.js

const mongoose = require('mongoose');

// Users/Voters Collection
const voterSchema = new mongoose.Schema({
  wallet_address: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  full_name: String,
  
  // Identity verification
  identity: {
    id_type: String, // 'national_id', 'passport', 'drivers_license'
    id_number_hash: String, // Hashed for privacy
    verified: Boolean,
    verified_at: Date,
    verified_by: String
  },
  
  // Registration status
  is_registered: {
    type: Boolean,
    default: false
  },
  registration_date: Date,
  
  // Voting history (election IDs only, not choices)
  voting_history: [{
    election_id: String,
    voted_at: Date,
    transaction_hash: String
  }],
  
  // Profile
  date_of_birth: Date,
  country: String,
  region: String,
  
  created_at: {
    type: Date,
    default: Date.now
  }
});

// Elections Metadata Collection (supplement to blockchain)
const electionSchema = new mongoose.Schema({
  election_id: {
    type: Number,
    required: true,
    unique: true
  },
  blockchain_address: String, // Contract address
  
  // Basic info
  title: {
    type: String,
    required: true
  },
  description: String,
  
  // Type and settings
  election_type: {
    type: String,
    enum: ['SingleChoice', 'MultipleChoice', 'YesNo', 'Ranked'],
    required: true
  },
  
  // Timeline
  start_time: {
    type: Date,
    required: true
  },
  end_time: {
    type: Date,
    required: true
  },
  
  // Eligibility
  eligibility_criteria: {
    min_age: Number,
    required_country: String,
    required_region: String,
    custom_requirements: [String]
  },
  
  // Candidates with rich media
  candidates: [{
    candidate_id: Number,
    name: String,
    description: String,
    image_url: String,
    party: String,
    manifesto_url: String,
    social_links: {
      twitter: String,
      website: String
    }
  }],
  
  // Status
  status: {
    type: String,
    enum: ['draft', 'scheduled', 'active', 'ended', 'results_published'],
    default: 'draft'
  },
  
  // Organization
  organization: {
    name: String,
    type: String, // 'government', 'corporate', 'nonprofit', 'community'
    logo_url: String
  },
  
  // Administrators
  admins: [String], // wallet addresses
  creator: {
    type: String,
    required: true
  },
  
  // Statistics (cached from blockchain)
  stats: {
    total_eligible_voters: Number,
    total_votes_cast: Number,
    turnout_percentage: Number,
    last_updated: Date
  },
  
  // Settings
  settings: {
    require_voter_registration: Boolean,
    allow_vote_verification: Boolean,
    publish_results_automatically: Boolean,
    anonymous_results: Boolean
  },
  
  created_at: {
    type: Date,
    default: Date.now
  },
  updated_at: Date
});

// Audit Log Collection (off-chain record of all actions)
const auditLogSchema = new mongoose.Schema({
  election_id: Number,
  action_type: {
    type: String,
    enum: [
      'election_created',
      'voter_registered',
      'vote_cast',
      'election_ended',
      'results_published',
      'admin_action'
    ],
    required: true
  },
  
  actor: String, // wallet address
  
  details: {
    type: mongoose.Schema.Types.Mixed
  },
  
  // Blockchain reference
  transaction_hash: String,
  block_number: Number,
  
  timestamp: {
    type: Date,
    default: Date.now,
    required: true
  },
  
  ip_address: String,
  user_agent: String
});

// Verification Requests Collection
const verificationRequestSchema = new mongoose.Schema({
  voter_address: {
    type: String,
    required: true
  },
  
  // Submitted documents (encrypted links)
  documents: [{
    type: String, // 'id_front', 'id_back', 'proof_of_residence'
    file_url: String, // Encrypted S3 URL
    uploaded_at: Date
  }],
  
  // Status
  status: {
    type: String,
    enum: ['pending', 'under_review', 'approved', 'rejected'],
    default: 'pending'
  },
  
  reviewed_by: String,
  reviewed_at: Date,
  rejection_reason: String,
  
  submitted_at: {
    type: Date,
    default: Date.now
  }
});

// Results Cache Collection (for faster querying)
const resultsCacheSchema = new mongoose.Schema({
  election_id: {
    type: Number,
    required: true,
    unique: true
  },
  
  results: [{
    candidate_id: Number,
    candidate_name: String,
    vote_count: Number,
    percentage: Number
  }],
  
  total_votes: Number,
  turnout_percentage: Number,
  
  // Winner(s)
  winners: [{
    candidate_id: Number,
    candidate_name: String,
    vote_count: Number
  }],
  
  last_updated: {
    type: Date,
    default: Date.now
  },
  
  is_final: Boolean
});

// Notifications Collection
const notificationSchema = new mongoose.Schema({
  voter_address: {
    type: String,
    required: true,
    index: true
  },
  
  type: {
    type: String,
    enum: [
      'election_created',
      'election_starting_soon',
      'election_started',
      'election_ending_soon',
      'election_ended',
      'results_published',
      'verification_approved',
      'verification_rejected'
    ],
    required: true
  },
  
  election_id: Number,
  
  title: String,
  message: String,
  
  is_read: {
    type: Boolean,
    default: false
  },
  
  created_at: {
    type: Date,
    default: Date.now
  }
});

// Organizations Collection (for enterprise voting)
const organizationSchema = new mongoose.Schema({
  organization_id: {
    type: String,
    required: true,
    unique: true
  },
  
  name: {
    type: String,
    required: true
  },
  
  type: {
    type: String,
    enum: ['government', 'corporate', 'nonprofit', 'community', 'academic']
  },
  
  // Contact
  contact: {
    email: String,
    phone: String,
    website: String
  },
  
  // Admins
  admins: [String], // wallet addresses
  
  // Settings
  settings: {
    max_concurrent_elections: Number,
    allow_anonymous_voting: Boolean,
    require_id_verification: Boolean
  },
  
  // Statistics
  stats: {
    total_elections: Number,
    total_voters: Number,
    total_votes_cast: Number
  },
  
  created_at: Date,
  is_verified: Boolean
});

// Indexes
voterSchema.index({ wallet_address: 1 });
voterSchema.index({ email: 1 });
electionSchema.index({ election_id: 1 });
electionSchema.index({ status: 1, start_time: 1 });
auditLogSchema.index({ election_id: 1, timestamp: -1 });
auditLogSchema.index({ actor: 1, timestamp: -1 });
notificationSchema.index({ voter_address: 1, is_read: 1, created_at: -1 });

module.exports = {
  Voter: mongoose.model('Voter', voterSchema),
  Election: mongoose.model('Election', electionSchema),
  AuditLog: mongoose.model('AuditLog', auditLogSchema),
  VerificationRequest: mongoose.model('VerificationRequest', verificationRequestSchema),
  ResultsCache: mongoose.model('ResultsCache', resultsCacheSchema),
  Notification: mongoose.model('Notification', notificationSchema),
  Organization: mongoose.model('Organization', organizationSchema)
};
