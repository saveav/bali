describe "TransactionRules" do
  subject(:transaction) { Transaction.new }
  let(:role) { nil }
  let(:user) { User.new(role: role) }

  it "can be updated" do
    expect(user).to be_able_to :update, transaction
  end

  it { expect(user).to be_able_to :update, transaction }
  it { expect(user).to be_able_to :print, transaction }
  it { expect(user).not_to be_able_to :unsettle, transaction }
  it { expect(user).not_to be_able_to :download, transaction }
  it { expect(user).not_to be_able_to :comment, transaction }

  it "can be settled if transaction is settled" do
    subject.settled = true
    expect(user).to be_able_to :unsettle, transaction
  end

  context "when supervisor" do
    let(:role) { :supervisor }

    it { expect(user).to be_able_to :update, transaction }
    it { expect(user).to be_able_to :print, transaction }
    it { expect(user).to be_able_to :unsettle, transaction }
    it { expect(user).not_to be_able_to :download, transaction }
    it { expect(user).to be_able_to :comment, transaction }
  end

  context "when accountant" do
    let(:role) { :accountant }

    it { expect(user).not_to be_able_to :update, transaction }
    it { expect(user).to be_able_to :print, transaction }
    it { expect(user).to be_able_to :unsettle, transaction }
    it { expect(user).not_to be_able_to :download, transaction }
    it { expect(user).not_to be_able_to :comment, transaction }
  end

  context "when clerk" do
    let(:role) { :clerk }

    it { expect(user).not_to be_able_to :update, transaction }
    it { expect(user).not_to be_able_to :print, transaction }
    it { expect(user).to be_able_to :unsettle, transaction }
    it { expect(user).not_to be_able_to :download, transaction }
    it { expect(user).not_to be_able_to :comment, transaction }
  end

  context "when admin" do
    let(:role) { :admin }

    it { expect(user).to be_able_to :update, transaction }
    it { expect(user).to be_able_to :print, transaction }
    it { expect(user).to be_able_to :unsettle, transaction }
    it { expect(user).to be_able_to :download, transaction }
    it { expect(user).to be_able_to :comment, transaction }
  end

  describe "when role is given as a string" do
    context "when clerk" do
      let(:role) { "clerk" }

      it { expect(user.role).to be_a String }
      it { expect(user).not_to be_able_to :update, transaction }
      it { expect(user).not_to be_able_to :print, transaction }
      it { expect(user).to be_able_to :unsettle, transaction }
      it { expect(user).not_to be_able_to :download, transaction }
      it { expect(user).not_to be_able_to :comment, transaction }
    end

    context "when admin" do
      let(:role) { "admin" }

      it { expect(user.role).to be_a String }
      it { expect(user).to be_able_to :update, transaction }
      it { expect(user).to be_able_to :print, transaction }
      it { expect(user).to be_able_to :unsettle, transaction }
      it { expect(user).to be_able_to :download, transaction }
      it { expect(user).to be_able_to :comment, transaction }
    end
  end

  describe "when there are multiple role" do
    let(:role) { ["accountant", "supervisor"] }

    it { expect(user.role).to be_an Array }
    it { expect(user).to be_able_to :update, transaction }
    it { expect(user).to be_able_to :print, transaction }
    it { expect(user).to be_able_to :unsettle, transaction }
    it { expect(user).not_to be_able_to :download, transaction }
    it { expect(user).to be_able_to :comment, transaction }
  end

  describe "when role is not defined" do
    let(:role) { :undefined }

    it { expect(user).to be_able_to :update, transaction }
    it { expect(user).to be_able_to :print, transaction }
    it { expect(user).not_to be_able_to :unsettle, transaction }
    it { expect(user).not_to be_able_to :download, transaction }
    it { expect(user).not_to be_able_to :comment, transaction }
  end
end
