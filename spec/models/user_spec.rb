require 'rails_helper'

RSpec.describe User, type: :model do
    describe 'username' do
        let(:user) { FactoryBot.build(:user) }

        it 'is not valid when blank' do
            user.username = ' '
            user.save

            expect(user).not_to be_valid
        end

        it 'is not valid when shorter than 3 letters' do
            user.username = 'aa'
            user.save

            expect(user).not_to be_valid
        end

        it 'is not valid when longer than 16 letters' do
            user.username = 'a' * 17
            user.save

            expect(user).not_to be_valid
        end

    end

    describe 'password' do
        let(:user) { FactoryBot.build(:user) }

        it 'is not valid when blank' do
            user.password = ' '
            user.save

            expect(user).not_to be_valid
        end

        it 'is not valid when shorter than 8 letters' do
            user.password = 'a' * 7
            user.save

            expect(user).not_to be_valid
        end

        it 'is not valid when longer than 32 letters' do
            user.password = 'a' * 33
            user.save

            expect(user).not_to be_valid
        end

    end
end