import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TopicOption {
  final String id;
  final String label;
  final String iconId;
  final Color color;

  const TopicOption({
    required this.id,
    required this.label,
    required this.iconId,
    required this.color,
  });
}

const List<TopicOption> topicOptions = [
  TopicOption(
      id: 'travel',
      label: 'Travel',
      iconId: 'topic_travel',
      color: AppColors.teal),
  TopicOption(
      id: 'business',
      label: 'Business',
      iconId: 'topic_business',
      color: AppColors.purple),
  TopicOption(
      id: 'social',
      label: 'Social',
      iconId: 'topic_social',
      color: AppColors.coral),
  TopicOption(
      id: 'daily_life',
      label: 'Daily Life',
      iconId: 'topic_dailyLife',
      color: AppColors.gold),
  TopicOption(
      id: 'technology',
      label: 'Technology',
      iconId: 'topic_technology',
      color: AppColors.formalTone),
  TopicOption(
      id: 'education',
      label: 'Education',
      iconId: 'topic_education',
      color: AppColors.tealDeep),
  TopicOption(
      id: 'food',
      label: 'Food',
      iconId: 'topic_food',
      color: AppColors.warning),
  TopicOption(
      id: 'healthcare',
      label: 'Healthcare',
      iconId: 'topic_healthcare',
      color: AppColors.success),
  TopicOption(
      id: 'shopping',
      label: 'Shopping',
      iconId: 'topic_shopping',
      color: AppColors.casualTone),
  TopicOption(
      id: 'entertainment',
      label: 'Entertainment',
      iconId: 'topic_entertainment',
      color: AppColors.purpleDeep),
  TopicOption(
      id: 'sports',
      label: 'Sports',
      iconId: 'topic_sports',
      color: AppColors.neutralTone),
  TopicOption(
      id: 'nature',
      label: 'Nature',
      iconId: 'topic_nature',
      color: AppColors.success),
  TopicOption(
      id: 'finance',
      label: 'Finance',
      iconId: 'topic_finance',
      color: AppColors.goldDeep),
  TopicOption(
      id: 'relationships',
      label: 'Relationships',
      iconId: 'topic_relationships',
      color: AppColors.coral),
  TopicOption(
      id: 'law',
      label: 'Law',
      iconId: 'topic_law',
      color: AppColors.formalTone),
  TopicOption(
      id: 'real_estate',
      label: 'Real Estate',
      iconId: 'topic_realEstate',
      color: AppColors.goldDark),
];
