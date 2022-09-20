require 'rails_helper'

RSpec.describe Plan, type: :model do
    let(:user) { FactoryBot.build(:user) }
    let(:plan) { FactoryBot.build(:plan, user: user) }

    it 'is not valid when blank' do
        plan.name = ' '
        plan.save

        expect(plan).not_to be_valid
    end

    it 'is not valid when shorter than 3 letters' do
        plan.name = 'aa'
        plan.save

        expect(plan).not_to be_valid
    end

    it 'is not valid when longer than 24 letters' do
        plan.name = 'a' * 25
        plan.save

        expect(plan).not_to be_valid
    end

    it 'is not valid when there is no user' do
        plan = FactoryBot.build(:plan)
        plan.save

        expect(plan).not_to be_valid
    end
end
