module Ion
  class DashboardController < ApplicationController

    before_filter :authenticate!

    def index
    end

    def quota
      @quota_cur = Ion::Quota::read
      @quota_cur = @quota_cur[:cur] if @quota_cur.has_key?(:cur)
      @quota_cur = 0 unless @quota_cur.is_a?(Integer)
      @quota_max = Rails.configuration.ion.max_quota_mb
      render layout: false
    end

  end
end
