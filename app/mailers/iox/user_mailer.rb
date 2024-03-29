module Iox
  class UserMailer < ActionMailer::Base

    # default_from is defined in the config/application.rb file

    def welcome_email(user, creator)
      @user = user
      @creator = creator
      @url  = "https://#{Rails.configuration.iox.domain_name}/iox/welcome/#{user.id}?k=#{user.confirmation_key}"
      @support_email = Rails.configuration.iox.support_email
      @site_title = Rails.configuration.iox.site_title
      mail( to: @user.email, subject: "[#{Rails.configuration.iox.site_title}] #{I18n.t('user.mailer.subject')}" )
    end

    def registration_welcome_email(user)
      @user = user
      @url  = "https://#{Rails.configuration.iox.domain_name}/iox/welcome/#{user.id}?k=#{user.confirmation_key}"
      @site_title = Rails.configuration.iox.site_title
      mail( to: @user.email, bcc: admin_emails, subject: "[#{Rails.configuration.iox.site_title}] #{I18n.t('user.registration_form.subject')}" )
    end

    def confirmation_email(user)
      @user = user
      @url  = "https://#{Rails.configuration.iox.domain_name}/iox/confirm/#{user.confirmation_key}"
      mail( to: @user.email, subject: "[#{Rails.configuration.iox.site_title}] #{I18n.t('user.mailer.welcome')}" )
    end

    def forgot_password(user)
      @user = user
      @url = "https://#{Rails.configuration.iox.domain_name}/iox/reset_password/#{user.id}?k=#{user.confirmation_key}"
      mail( to: @user.email, subject: "[#{Rails.configuration.iox.site_title}] #{I18n.t('auth.forgot_password_request')}" )
    end

    private

    def admin_emails
      User.admins.map{ |u| u.email }
    end

  end
end
