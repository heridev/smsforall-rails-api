# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_params) do
    {
      email: 'p@elh.mx',
      password: 'password1',
      name: 'Heriberto Perez',
      mobile_number: '3121231111',
      country_international_code: '52'
    }
  end

  describe 'validations' do
    context 'validates format of email' do
      context 'when the email format is invalid' do
        it 'returns a format error when the domains is missing' do
          user = build(:user, email: 'email@example')
          expect(user.valid?).to be_falsey
          expect(user.errors.messages[:email].first).to include('is invalid')
        end

        it 'returns a format error when the @ is missing' do
          user = build(:user, email: 'email.example.com')
          expect(user.valid?).to be_falsey
          expect(user.errors.messages[:email].first).to include('is invalid')
        end
      end

      context 'when the email format is valid' do
        it 'does not return any error' do
          user = build(:user, email: 'email@example.com')
          expect(user.valid?).to be_truthy
        end

        it 'accepts a subdomain name as a valid domain' do
          user = build(:user, email: 'email@subdomain.example.com')
          expect(user.valid?).to be_truthy
        end

        it 'detects as valid an email with different domain names' do
          user = build(:user, email: 'email@example.io')
          expect(user.valid?).to be_truthy

          user = build(:user, email: 'heriberto@example.com', mobile_number: '3121708999')
          expect(user.valid?).to be_truthy

          user = build(:user, email: 'heriberto+2@example.com', mobile_number: '3121009089')
          expect(user.valid?).to be_truthy
        end
      end
    end
  end

  describe '.persist_values' do
    before do
      user = create(:user, mobile_number: '3121899980')
      create(:sms_mobile_hub, is_master: true, user: user)
    end

    let(:user) { User.persist_values(valid_params) }

    context 'when the params are valid' do
      it 'creates a new user with valid tokens' do
        user = User.persist_values(valid_params)
        expect(user.valid?).to be_truthy
      end

      it 'enqueues a new job to prepare the account' do
        User.persist_values(valid_params)
        job = find_enqueued_job_by(ServiceEnqueuerJob)
        expect(job[:args].size).to eq 3
        expect(job[:queue]).to eq 'urgent_delivery'
      end

      it 'generates the api keys' do
        perform_enqueued_jobs { user }
        expect(user.third_party_applications.size).to eq 1
      end

      it 'generates the sms notifications' do
        perform_enqueued_jobs { user }
        expect(user.sms_notifications.size).to eq 1
      end

      it 'generates the registration pin code' do
        perform_enqueued_jobs { user }
        expect(user.reload.registration_pin_code).to be_present
        expect(user.registration_pin_code.size).to eq 6
      end
    end

    context 'when the params are invalid' do
      it 'does not create a new user with valid tokens' do
        invalid_params = valid_params
        invalid_params[:password] = nil
        user = User.persist_values(invalid_params)
        expect(user.errors.full_messages.first).to match(/Passwor/)
        expect(user.valid?).to be_falsey
      end
    end
  end

  describe '.valid_authentication?' do
    let!(:valid_user) { User.persist_values(valid_params) }

    context 'when the email and password are valid' do
      it 'returns the user when' do
        result = User.auth_by_email_and_password(
          valid_params[:email],
          valid_params[:password]
        )

        expect(result.email).to eq valid_params[:email]
      end
    end

    context 'when the email and password are invalid' do
      it 'returns the user when' do
        result = User.auth_by_email_and_password(
          valid_params[:email],
          'otherpass'
        )
        expect(result).to be_falsey
      end
    end
  end
end
