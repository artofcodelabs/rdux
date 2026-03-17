# frozen_string_literal: true

class ActionResult
  class << self
    def call(action:, resources:, **custom) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      result = { relations: {}, db_changes: {} }

      resources.each do |resource|
        if resource.is_a?(Hash)
          result[:relations].merge!(resource)
          next
        end

        key = relation_key(resource)
        result[:relations][key] = resource.id
        result[:db_changes][key] = resource.saved_changes if resource.saved_changes.present?
      end

      persist_relations(result[:relations], action.id)
      result.merge(custom)
    end

    private

    def relation_key(resource)
      "#{resource.class.name.underscore}##{resource.id}"
    end

    def resource_type_for(name)
      type = name.sub(/_id$/, '').sub(/#\d+$/, '').camelize
      resource_class = type.safe_constantize
      resource_class && resource_class < ApplicationRecord ? type : nil
    end

    def persist_relations(relations, action_id)
      relations.each do |name, id|
        resource_type = resource_type_for(name)
        next if resource_type.nil? || !id.to_s.match?(/\A\d+\z/)

        ActionResource.create!(action_id:, resource_type:, resource_id: id)
      end
    end
  end
end
