import 'package:flutter/material.dart';

class SoundTrack {
  final String id;
  final String title;
  final String description;
  final String assetPath;
  final IconData icon;
  final String category;

  const SoundTrack({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.icon,
    required this.category,
  });

  static const List<SoundTrack> defaultTracks = [
    SoundTrack(
      id: 'waterfall',
      title: 'Cascading Waterfall',
      description: 'Deep, steady roar of rushing fresh water',
      assetPath: 'assets/sounds/waterfall.wav',
      icon: Icons.water_rounded,
      category: 'Water',
    ),
    SoundTrack(
      id: 'ocean',
      title: 'Ocean Waves',
      description: 'Gentle, rolling sea tides washing ashore',
      assetPath: 'assets/sounds/ocean.wav',
      icon: Icons.waves_rounded,
      category: 'Water',
    ),
    SoundTrack(
      id: 'rainfall',
      title: 'Soothing Rainfall',
      description: 'Soft summer rain falling on leaves',
      assetPath: 'assets/sounds/rainfall.wav',
      icon: Icons.grain_rounded,
      category: 'Water',
    ),
    SoundTrack(
      id: 'pink_noise',
      title: 'Pink Noise',
      description: 'Balanced frequency spectrum for deep restful sleep',
      assetPath: 'assets/sounds/pink_noise.wav',
      icon: Icons.graphic_eq_rounded,
      category: 'Noise',
    ),
    SoundTrack(
      id: 'brown_noise',
      title: 'Deep Brown Noise',
      description: 'Rich low-frequency rumble that calms the mind',
      assetPath: 'assets/sounds/brown_noise.wav',
      icon: Icons.blur_linear_rounded,
      category: 'Noise',
    ),
    SoundTrack(
      id: 'forest',
      title: 'Gentle Forest Breeze',
      description: 'Whispering trees with subtle woodland tones',
      assetPath: 'assets/sounds/forest.wav',
      icon: Icons.park_rounded,
      category: 'Nature',
    ),
    SoundTrack(
      id: 'crickets',
      title: 'Night Crickets',
      description: 'Peaceful evening chirping under starlit skies',
      assetPath: 'assets/sounds/crickets.wav',
      icon: Icons.nightlight_round,
      category: 'Nature',
    ),
  ];
}
