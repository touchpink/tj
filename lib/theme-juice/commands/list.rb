# encoding: UTF-8

module ThemeJuice
  class Command::List < ::ThemeJuice::Command

    #
    # @param {Hash} opts
    #
    # @return {Void}
    #
    def initialize(opts = {})
      super
      ::ThemeJuice::Service::List.new.list
    end
  end
end