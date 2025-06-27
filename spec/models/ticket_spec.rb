require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'validations' do
    it 'is valid with title, description, and customer' do
      ticket = build(:ticket)
      expect(ticket).to be_valid
    end

    it 'is invalid without a title' do
      ticket = build(:ticket, title: nil)
      expect(ticket).not_to be_valid
    end

    it 'is invalid without a description' do
      ticket = build(:ticket, description: nil)
      expect(ticket).not_to be_valid
    end

    it 'is invalid without a customer' do
      ticket = build(:ticket, customer: nil)
      expect(ticket).not_to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:customer).class_name('User') }
    it { should belong_to(:agent).class_name('User').optional }
    it { should have_many(:comments) }
  end

  describe 'enums' do
    it 'defines the expected statuses' do
      expect(described_class.statuses).to eq({
        "open" => 0,
        "in_progress" => 1,
        "closed" => 2
      })
    end

    it 'defaults to open' do
      ticket = build(:ticket)
      expect(ticket.status).to eq('open')
    end
  end
end
