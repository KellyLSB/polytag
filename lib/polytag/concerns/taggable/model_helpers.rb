module Polytag
  module Concerns
    module Taggable
      class ModelHelpers
        def initialize(owner)
          @owner = owner
        end

        def new(tag, args = {})
          ::Polytag.get tag: tag,
            foc: :first_or_create,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            tagged: @owner
        end
        alias add new
        alias create new

        def del(tag, args = {})
          return false unless exist?(tag, args)
          tag = ::Polytag.get tag: tag,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            tagged: @owner,
            foc: :first

          tag.destroy
          true
        end
        alias delete del
        alias remove del
        alias destroy del

        def get(tag, args = {})
          return false unless exist?(tag, args)
          ::Polytag.get tag: tag,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            tagged: @owner,
            foc: :first
        end
        alias find get

        def exist?(tag, args = {})
          tag = ::Polytag.get tag: tag,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            tagged: @owner,
            foc: :first

          # Return the result
          tag.is_a?(::Polytag::Connection)
        rescue ActiveRecord::RecordNotFound
          false
        end
        alias has_tag? exist?

        def shares_with(object, tag, args = {})

          # Ensure this is a taggable
          object = Polytag.get_tag_owner_or_taggable(:taggable, object)

          # Run a check to ensure the two object share a tag
          object.tag.get(tag, args) == (tag = get(tag, args)) ? tag : false
        end

        def shares_with?(object, tag, args = {})
          shares_with(object, tag, args) ? true : false
        end

        def others_with_tag(tag, args = {})
          tag = ::Polytag.get tag: tag,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            tagged: @owner,
            foc: nil

          # Get a list of the connections that are shared through this tag
          ::Polytag::Connection.where(polytag_tag_id: tag.select(:polytag_tag_id))
        end
        alias associated_models others_with_tag
      end
    end
  end
end