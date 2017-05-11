module Auth
  module ActionState
    extend ActiveSupport::Concern

    included do
      scope :for, (lambda do |subject|
        if subject? && !subject.is_a?(Symbol)
          subject_name = Util.get_subject_name(subject)
          where(subject_name => subject)
        else
          all
        end
      end)
    end

    class_methods do
      attr_reader :subject
      attr_reader :association_name

      def subject?
        @has_subject
      end

      def init_model(options)
        self.table_name = options[:table_name]
        @association_name = table_name.to_sym
        init_actor options[:actor]
        init_subject options[:subject], options[:subject_options]
      end

      private

      def init_actor(actor)
        actor_name = actor.name.underscore.to_sym
        belongs_to actor_name

        actor.has_many @association_name, class_name: name, foreign_key: "#{actor_name}_id",
                                          dependent: :delete_all
      end

      def init_subject(subject, subject_options)
        @subject = subject
        subject_s = subject.to_s
        @has_subject = subject_s.singularize == subject_s

        if subject?
          belongs_to subject, subject_options
          subject_cls = reflect_on_all_associations(:belongs_to).second.klass

          subject_cls.has_many @association_name, class_name: name, foreign_key: "#{subject}_id",
                                                  dependent: :delete_all
        end
      end
    end
  end
end
