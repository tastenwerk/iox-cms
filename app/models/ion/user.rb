module Ion

  class User < ActiveRecord::Base

    include Ion::FileObject

    # password protection, auto-encryption, auto-decryption
    # see
    # http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html
    has_secure_password

    # paperclip plugin
    has_attached_file :avatar, :styles => { :original => "256x256#", :thumb => "32x32#" },
                      :default_url => "/assets/ion/avatar/:style/missing.png",
                      :url => "/data/avatars/:hash.:extension",
                      :hash_secret => "5b1b59b59b08dfea721470feed062327909b8f91"

    validates_attachment_content_type :avatar, content_type: [ "image/jpeg", "image/png", "image/jpg" ]

    validates :email, presence: true,
                      uniqueness: true,
                      format: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/i

    validates :username, presence: true,
                      uniqueness: true

    before_create :gen_confirmation_key, :gen_user_settings

    before_validation :gen_password_if_empty, on: :create

    attr_accessor :send_welcome_msg

    def full_name
      str = ""
      str << self.firstname unless self.firstname.blank?
      unless self.lastname.blank?
        str << " " unless str.blank?
        str << self.lastname
      end
      if str.blank?
        str << self.username
      end
      str
    end
    alias_method :name, :full_name

    def gen_user_settings
    end

    def gen_confirmation_key
      self.confirmation_key = Digest::SHA256::hexdigest( self.password )
      self.confirmation_key_valid_until = 36.hours.from_now
    end

    def gen_password_if_empty
      if( self.password.blank? )
        pw = Digest::SHA256::hexdigest( self.username + Time.now.to_s )[0..7]
        self.password = self.password_confirmation = pw
      end
    end

    def is_admin?
      self.roles && self.roles.include?('admin')
    end

    def is_editor?
      self.roles && self.roles.include?('editor')
    end

    def can_manage?( appname )
      is_admin? || can_write_apps.downcase.include?( appname.to_s.downcase )
    end

  end

end