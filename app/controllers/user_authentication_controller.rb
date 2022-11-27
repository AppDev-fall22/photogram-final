class UserAuthenticationController < ApplicationController
  # Uncomment line 3 in this file and line 5 in ApplicationController if you want to force users to sign in before any other actions.
  # skip_before_action(:force_user_sign_in, { :only => [:sign_up_form, :create, :sign_in_form, :create_cookie] })

  def sign_in_form
    render({ :template => "user_authentication/sign_in.html.erb" })
  end

  def show_feed
    the_username = params.fetch("username")
    @the_user = User.where(:username => the_username).first
    render({ :template => "user_authentication/feed.html.erb"})
  end

  def show_liked_photos
    @matching_user = params.fetch("username")
    @the_user = User.where(:username => @matching_user).first
    @liked_photos = Like.where(:fan_id => @the_user.id)

    render({:template => "likes/index.html.erb"})
  end

  def show
      the_name = params.fetch("username")
      @the_user = User.where( :username => the_name).first

      @user_photos = @the_user.photo_list
      @followers = FollowRequest.where(:recipient_id => @the_user.id).where(:status => "accepted")
      @following = FollowRequest.where(:sender_id => @the_user.id).where(:status => "accepted")

      if session[:user_id] != nil
        render({ :template => "user_authentication/show.html.erb"})
      else
        redirect_to("/user_sign_in", { :alert => "You have to sign in first." })
      end
  end

  def create_cookie
    user = User.where({ :email => params.fetch("query_email") }).first

    the_supplied_password = params.fetch("query_password")

    if user != nil
      are_they_legit = user.authenticate(the_supplied_password)

      if are_they_legit == false
        redirect_to("/user_sign_in", { :alert => "Incorrect password." })
      else
        session[:user_id] = user.id

        redirect_to("/", { :notice => "Signed in successfully." })
      end
    else
      redirect_to("/user_sign_in", { :alert => "No user with that email address." })
    end
  end

  def destroy_cookies
    reset_session

    redirect_to("/", { :notice => "Signed out successfully." })
  end

  def sign_up_form
    render({ :template => "user_authentication/sign_up.html.erb" })
  end

  def create
    @user = User.new
    @user.email = params.fetch("query_email")
    @user.password = params.fetch("query_password")
    @user.password_confirmation = params.fetch("query_password_confirmation")
    @user.comments_count = params.fetch("query_comments_count")
    @user.likes_count = params.fetch("query_likes_count")
    @user.private = params.fetch("query_private", false)
    @user.username = params.fetch("query_username")

    save_status = @user.save

    if save_status == true
      session[:user_id] = @user.id

      redirect_to("/", { :notice => "User account created successfully." })
    else
      redirect_to("/user_sign_up", { :alert => @user.errors.full_messages.to_sentence })
    end
  end

  def edit_profile_form
    render({ :template => "user_authentication/edit_profile.html.erb" })
  end

  def index
    matching_users = User.all

    @list_of_users = matching_users.order({ :username => :asc})

    if session[:user_id] == nil
      render({ :template => "user_authentication/user_list_regular.html.erb" })
    else
      render({ :template => "user_authentication/user_list_signin.html.erb" })
    end
  end

  def update
    @user = @current_user
    @user.email = params.fetch("query_email")
    @user.password = params.fetch("query_password")
    @user.password_confirmation = params.fetch("query_password_confirmation")
    @user.comments_count = params.fetch("query_comments_count")
    @user.likes_count = params.fetch("query_likes_count")
    @user.private = params.fetch("query_private", false)
    @user.username = params.fetch("query_username")

    if @user.valid?
      @user.save

      redirect_to("/", { :notice => "User account updated successfully." })
    else
      render({ :template => "user_authentication/edit_profile_with_errors.html.erb", :alert => @user.errors.full_messages.to_sentence })
    end
  end

  def destroy
    @current_user.destroy
    reset_session

    redirect_to("/", { :notice => "User account cancelled" })
  end
end
