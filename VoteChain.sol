// File: frontend/src/components/VoterDashboard.tsx
// How to name: frontend/src/components/VoterDashboard.tsx

import React, { useState } from 'react';
import { Vote, Shield, CheckCircle, Clock, Users, TrendingUp, Lock, Eye } from 'lucide-react';

const VoteChainDashboard = () => {
  const [activeTab, setActiveTab] = useState('active');
  const [selectedElection, setSelectedElection] = useState<any>(null);
  const [votingStep, setVotingStep] = useState<'select' | 'confirm' | 'success' | null>(null);
  const [selectedCandidate, setSelectedCandidate] = useState<number | null>(null);

  const [elections] = useState([
    {
      election_id: 1,
      title: '2025 City Mayor Election',
      description: 'Vote for the next mayor of Metro City',
      type: 'SingleChoice',
      start_time: new Date('2025-10-15'),
      end_time: new Date('2025-10-22'),
      status: 'active',
      total_votes: 15420,
      eligible_voters: 50000,
      turnout: 30.84,
      has_voted: false,
      candidates: [
        { id: 0, name: 'Sarah Johnson', party: 'Progressive', image: '👩', votes: 8200 },
        { id: 1, name: 'Michael Chen', party: 'Conservative', image: '👨', votes: 7220 }
      ]
    },
    {
      election_id: 2,
      title: 'Community Park Referendum',
      description: 'Should we build a new community park?',
      type: 'YesNo',
      start_time: new Date('2025-10-10'),
      end_time: new Date('2025-10-20'),
      status: 'active',
      total_votes: 3240,
      eligible_voters: 10000,
      turnout: 32.4,
      has_voted: true,
      candidates: [
        { id: 0, name: 'Yes', party: '', image: '✅', votes: 2100 },
        { id: 1, name: 'No', party: '', image: '❌', votes: 1140 }
      ]
    },
    {
      election_id: 3,
      title: 'School Board Election',
      description: 'Elect 3 members to the school board',
      type: 'MultipleChoice',
      start_time: new Date('2025-09-01'),
      end_time: new Date('2025-09-30'),
      status: 'ended',
      total_votes: 8500,
      eligible_voters: 15000,
      turnout: 56.67,
      results_published: true,
      has_voted: true,
      candidates: [
        { id: 0, name: 'Emma Davis', party: '', image: '👩', votes: 4200 },
        { id: 1, name: 'James Wilson', party: '', image: '👨', votes: 3100 },
        { id: 2, name: 'Lisa Martinez', party: '', image: '👩', votes: 1200 }
      ]
    }
  ]);

  const getDaysRemaining = (endDate: Date) => {
    const now = new Date();
    const diff = endDate.getTime() - now.getTime();
    return Math.ceil(diff / (1000 * 60 * 60 * 24));
  };

  const getStatusBadge = (status: string, hasVoted: boolean) => {
    if (hasVoted && status === 'active') {
      return <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm font-semibold flex items-center gap-1">
        <CheckCircle className="w-4 h-4" /> Voted
      </span>;
    }
    if (status === 'active') {
      return <span className="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm font-semibold flex items-center gap-1">
        <Clock className="w-4 h-4" /> Active
      </span>;
    }
    return <span className="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm font-semibold">Ended</span>;
  };

  const handleVote = (election: any, candidateId: number) => {
    setSelectedElection(election);
    setSelectedCandidate(candidateId);
    setVotingStep('confirm');
  };

  const confirmVote = () => {
    // Simulate blockchain transaction
    setVotingStep('success');
    
    setTimeout(() => {
      setVotingStep(null);
      setSelectedElection(null);
      setSelectedCandidate(null);
    }, 3000);
  };

  const filteredElections = elections.filter(e => {
    if (activeTab === 'active') return e.status === 'active';
    if (activeTab === 'voted') return e.has_voted;
    if (activeTab === 'ended') return e.status === 'ended';
    return true;
  });

  // Voting Modal
  if (votingStep === 'confirm' && selectedElection) {
    const candidate = selectedElection.candidates[selectedCandidate!];
    
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
        <div className="bg-white rounded-3xl shadow-2xl p-8 max-w-lg w-full">
          <div className="text-center mb-6">
            <Shield className="w-16 h-16 text-blue-600 mx-auto mb-4" />
            <h2 className="text-3xl font-bold text-gray-800 mb-2">Confirm Your Vote</h2>
            <p className="text-gray-600">Please review your choice before submitting</p>
          </div>

          <div className="bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl p-6 mb-6 border-2 border-blue-200">
            <div className="text-center mb-4">
              <div className="text-6xl mb-3">{candidate.image}</div>
              <h3 className="text-2xl font-bold text-gray-800">{candidate.name}</h3>
              {candidate.party && <p className="text-gray-600">{candidate.party}</p>}
            </div>
            <div className="bg-white rounded-lg p-4">
              <p className="text-sm text-gray-700"><strong>Election:</strong> {selectedElection.title}</p>
            </div>
          </div>

          <div className="bg-yellow-50 border-2 border-yellow-300 rounded-xl p-4 mb-6">
            <div className="flex items-start gap-3">
              <Lock className="w-5 h-5 text-yellow-600 mt-0.5" />
              <div className="text-sm text-yellow-800">
                <p className="font-semibold mb-1">Important</p>
                <p>Your vote will be recorded on the blockchain and cannot be changed. Your choice remains anonymous.</p>
              </div>
            </div>
          </div>

          <div className="flex gap-4">
            <button
              onClick={() => setVotingStep(null)}
              className="flex-1 px-6 py-4 bg-gray-200 text-gray-800 rounded-xl font-bold hover:bg-gray-300 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={confirmVote}
              className="flex-1 px-6 py-4 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-xl font-bold hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg"
            >
              Confirm Vote
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Success Modal
  if (votingStep === 'success') {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
        <div className="bg-white rounded-3xl shadow-2xl p-8 max-w-lg w-full text-center">
          <div className="w-24 h-24 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle className="w-12 h-12 text-green-600" />
          </div>
          <h2 className="text-3xl font-bold text-gray-800 mb-4">Vote Recorded!</h2>
          <p className="text-gray-600 mb-6">Your vote has been securely recorded on the blockchain</p>
          
          <div className="bg-gray-50 rounded-xl p-4 mb-6">
            <p className="text-sm text-gray-700 mb-2"><strong>Transaction Hash:</strong></p>
            <p className="text-xs text-gray-500 font-mono break-all">0xabcd...1234</p>
          </div>

          <div className="text-6xl mb-4">🎉</div>
          <p className="text-sm text-gray-500">Thank you for participating in democracy!</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2 flex items-center gap-3">
            <Vote className="w-10 h-10 text-blue-600" />
            VoteChain
          </h1>
          <p className="text-gray-600">Secure blockchain voting platform</p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-blue-500">
            <div className="flex items-center justify-between mb-2">
              <Vote className="w-6 h-6 text-blue-500" />
              <span className="text-xs text-gray-500">Active</span>
            </div>
            <div className="text-3xl font-bold text-gray-800">2</div>
            <div className="text-sm text-gray-500">Elections</div>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-green-500">
            <div className="flex items-center justify-between mb-2">
              <CheckCircle className="w-6 h-6 text-green-500" />
              <span className="text-xs text-gray-500">Your</span>
            </div>
            <div className="text-3xl font-bold text-gray-800">1</div>
            <div className="text-sm text-gray-500">Votes Cast</div>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-purple-500">
            <div className="flex items-center justify-between mb-2">
              <Shield className="w-6 h-6 text-purple-500" />
              <span className="text-xs text-gray-500">Verified</span>
            </div>
            <div className="text-3xl font-bold text-gray-800">✓</div>
            <div className="text-sm text-gray-500">Identity</div>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 border-l-4 border-orange-500">
            <div className="flex items-center justify-between mb-2">
              <Users className="w-6 h-6 text-orange-500" />
              <span className="text-xs text-gray-500">Total</span>
            </div>
            <div className="text-3xl font-bold text-gray-800">18.7K</div>
            <div className="text-sm text-gray-500">Votes</div>
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-xl shadow-lg p-2 mb-8 flex gap-2">
          {[
            { id: 'active', label: 'Active Elections', count: 2 },
            { id: 'voted', label: 'Already Voted', count: 1 },
            { id: 'ended', label: 'Past Elections', count: 1 }
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex-1 px-6 py-3 rounded-lg font-semibold transition-all ${
                activeTab === tab.id
                  ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg'
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
            >
              {tab.label} ({tab.count})
            </button>
          ))}
        </div>

        {/* Elections List */}
        <div className="space-y-6">
          {filteredElections.map(election => (
            <div key={election.election_id} className="bg-white rounded-2xl shadow-xl p-8">
              {/* Election Header */}
              <div className="flex items-start justify-between mb-6">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <h2 className="text-2xl font-bold text-gray-800">{election.title}</h2>
                    {getStatusBadge(election.status, election.has_voted)}
                  </div>
                  <p className="text-gray-600 mb-4">{election.description}</p>
                  
                  <div className="flex items-center gap-6 text-sm text-gray-500">
                    <div className="flex items-center gap-2">
                      <Clock className="w-4 h-4" />
                      {election.status === 'active' ? (
                        <span>{getDaysRemaining(election.end_time)} days remaining</span>
                      ) : (
                        <span>Ended {election.end_time.toLocaleDateString()}</span>
                      )}
                    </div>
                    <div className="flex items-center gap-2">
                      <Users className="w-4 h-4" />
                      <span>{election.total_votes.toLocaleString()} votes cast</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <TrendingUp className="w-4 h-4" />
                      <span>{election.turnout.toFixed(1)}% turnout</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Candidates */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {election.candidates.map(candidate => {
                  const percentage = election.total_votes > 0 
                    ? (candidate.votes / election.total_votes * 100).toFixed(1)
                    : '0.0';

                  return (
                    <div
                      key={candidate.id}
                      className={`p-6 rounded-xl border-2 transition-all ${
                        election.status === 'ended' || election.results_published
                          ? 'bg-gray-50 border-gray-200'
                          : election.has_voted
                          ? 'bg-gray-50 border-gray-200 cursor-not-allowed'
                          : 'bg-gradient-to-r from-blue-50 to-purple-50 border-blue-200 hover:border-blue-400 cursor-pointer'
                      }`}
                      onClick={() => {
                        if (election.status === 'active' && !election.has_voted) {
                          handleVote(election, candidate.id);
                        }
                      }}
                    >
                      <div className="flex items-center gap-4">
                        <div className="text-5xl">{candidate.image}</div>
                        <div className="flex-1">
                          <h3 className="text-xl font-bold text-gray-800">{candidate.name}</h3>
                          {candidate.party && (
                            <p className="text-sm text-gray-600">{candidate.party}</p>
                          )}
                        </div>
                      </div>

                      {/* Show results if ended or voted */}
                      {(election.status === 'ended' || election.results_published) && (
                        <div className="mt-4">
                          <div className="flex items-center justify-between mb-2">
                            <span className="text-sm text-gray-600">Votes</span>
                            <span className="text-lg font-bold text-gray-800">{percentage}%</span>
                          </div>
                          <div className="w-full bg-gray-200 rounded-full h-3">
                            <div
                              className="bg-gradient-to-r from-blue-500 to-purple-500 h-3 rounded-full transition-all duration-500"
                              style={{ width: `${percentage}%` }}
                            />
                          </div>
                          <p className="text-xs text-gray-500 mt-1">
                            {candidate.votes.toLocaleString()} votes
                          </p>
                        </div>
                      )}

                      {/* Vote button */}
                      {election.status === 'active' && !election.has_voted && (
                        <button className="w-full mt-4 bg-gradient-to-r from-blue-600 to-purple-600 text-white py-3 rounded-lg font-bold hover:from-blue-700 hover:to-purple-700 transition-all shadow-lg">
                          Vote for {candidate.name}
                        </button>
                      )}
                    </div>
                  );
                })}
              </div>

              {/* Blockchain Info */}
              <div className="mt-6 bg-gray-50 rounded-xl p-4 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Shield className="w-5 h-5 text-blue-600" />
                  <div>
                    <p className="text-sm font-semibold text-gray-800">Secured by Blockchain</p>
                    <p className="text-xs text-gray-600">All votes are immutable and verifiable</p>
                  </div>
                </div>
                <button className="flex items-center gap-2 text-sm text-blue-600 font-semibold hover:text-blue-700">
                  <Eye className="w-4 h-4" />
                  View on Explorer
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Empty State */}
        {filteredElections.length === 0 && (
          <div className="bg-white rounded-2xl shadow-xl p-12 text-center">
            <div className="text-8xl mb-4">🗳️</div>
            <h2 className="text-2xl font-bold text-gray-800 mb-2">No Elections Found</h2>
            <p className="text-gray-600">Check back later for upcoming elections</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default VoteChainDashboard;
