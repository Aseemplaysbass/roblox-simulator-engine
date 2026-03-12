# roblox-simulator-engine
Modular Roblox simulator game engine with pets, ascensions, eggs, trading, and persistent player data systems.

# Roblox Simulator Engine

A modular multiplayer simulator game built using Roblox Studio and Luau scripting.

The project implements a large-scale simulator architecture including player progression, pet systems, economy mechanics, and persistent player data.

## Core Systems

Progression
- Ascension / rebirth system
- Island unlock progression
- Portal teleportation

Pets
- Pet inventory and bank
- Pet enchantment and rainbow upgrades
- Pet index system

Economy
- Click-based currency system
- Shop and upgrade systems
- Code redemption and boosts

Rewards
- Egg hatching system
- Chest rewards
- Random gift system
- Spin rewards

Player Systems
- Achievements and badges
- Leaderboards
- Offline earnings

Infrastructure
- Persistent player data using ProfileService
- Custom admin commands using Cmdr
- Modular client-server architecture

Player
   ↓
Client GUI
   ↓
RemoteEvents
   ↓
Server Systems
   ↓
ProfileService
   ↓
Roblox DataStore
