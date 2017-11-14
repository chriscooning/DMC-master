require 'spec_helper'

describe GalleryInviter do
  let(:invitation_hash) { "123456" }
  let(:owner) { create(:user) }
  let(:gallery) { create(:gallery, user: owner) }
  let(:second_gallery) { create(:gallery, user: owner) }
  let(:subject) { GalleryInviter.new(as: owner, params: params) }

  def create_invitation(email = 'email@test.com', gallery_id = gallery.id, role = 'admin')
    InvitationRequest.create(
      email: email,
      invitation_hash: invitation_hash,
      gallery_id: gallery_id,
      role: role
    ) 
  end

  describe "registration with token" do

    before do
      create_invitation
      @user = create(:user, invitation_hash: invitation_hash)
    end

    it("should create membership for user") { @user.should have(1).gallery_membership }

    it("should destroy related requests") { gallery.should have(0).invites }
  end

  describe "inviting unregistered user" do
    let(:params) do
      {
        email: "email@gmail.com",
        gallery_ids: [gallery.id],
        role: "admin"
      }
    end

    before { subject.invite }

    it("should create invitations") { gallery.should have(1).invites }

    describe "second time with the same email" do
      let(:params2) do
        {
          email: "email@gmail.com",
          gallery_ids: [second_gallery.id],
          role: "admin"
        }
      end

      before do
        subject.invite
        GalleryInviter.new(as: owner, params: params2).invite
      end

      it("should assign the same invitation hash") do
        hashes = InvitationRequest.where(email: "email@gmail.com").pluck(:invitation_hash)
        hashes.uniq.should have(1).items
      end
    end
  end

  describe "inviting registered user" do
    let(:params) do
      {
        email: 'some@email.com',
        gallery_ids: gallery.id,
        role: 'admin'
      }
    end

    before do 
      create(:user, email: 'some@email.com')
      subject.invite
    end

    it("should create gallery members"){ gallery.should have(1).members }
  end

  describe "destroying invitation by email" do
    let(:params) do
      {
        email: 'some@email.com',
        gallery_ids: gallery.id
      }
    end

    context "for registered user" do
      before do
        @user = create(:user, email: 'some@email.com')
        @user.gallery_membership.create(gallery: gallery)
        @user.gallery_membership.create(gallery: second_gallery)
        subject.destroy_invitation_by_email
      end

      it("should destroy user membership") { @user.should have(1).gallery_membership }
    end

    context "for unregistered user" do
      before do
        create_invitation('some@email.com')
        subject.destroy_invitation_by_email
      end

      it("should destroy invitation requests") { gallery.should have(0).invites }
    end
  end
end