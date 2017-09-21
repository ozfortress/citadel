module Forums
  module TopicsHelper
    include Forums::Permissions

    ISOLATE_CONFIRM_MESSAGE = "Are you sure you want to unisolate this Topic?\n"\
                              'This means any admin will be able to manage this Topic.'.freeze

    UNISOLATE_CONFIRM_MESSAGE = "Are you sure you want to isolate this Topic?\n"\
                                'This means only you and anyone you give access '\
                                'to will be able to manage this Topic.'.freeze
  end
end
