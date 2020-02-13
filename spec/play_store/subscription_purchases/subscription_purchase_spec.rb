require "spec_helper"

describe CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase do
  subject { CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase.new(fake_subscription_purchase) }

  describe "expired and canceled subscription" do
    let(:fake_subscription_purchase) do
      FakeSubscriptionPurchase.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1459540113244,
        expiry_time_millis: 1462132088610,
        auto_renewing: false,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 0,
        payment_state: 1,
      )
    end

    it "is expired?" do
      subject.expired?.must_be_true
    end

    it "is canceled by user" do
      subject.canceled_by_user?.must_be_true
    end

    it "returns the payment_state" do
      subject.payment_state.must_equal 1
    end

    it "considers a payment as valid" do
      subject.payment_received?.must_be_true
    end

    it "checks that auto renewal status is false" do
      subject.auto_renewing?.must_be_false
    end

    it "returns the developer_payload" do
      subject.developer_payload.must_equal \
        "payload that gets stored and returned"
    end

    it "returns the kind" do
      subject.kind.must_equal "androidpublisher#subscriptionPurchase"
    end

    it "returns the start_time_millis" do
      subject.start_time_millis.must_equal 145_954_011_324_4
    end

    it "returns the expiry_time_millis" do
      subject.expiry_time_millis.must_equal 146_213_208_861_0
    end

    it "returns the starts_at" do
      expected = DateTime.new(2016, 4, 1, 19, 48, 33)
      subject.starts_at.must_equal expected
    end

    it "returns the expires_at" do
      expected = DateTime.new(2016, 5, 1, 19, 48, 8)
      subject.expires_at.must_equal expected
    end
  end

  describe "unexpired and renewing subscription" do
    two_days_from_now = DateTime.now + 2
    let(:fake_subscription_purchase) do
      FakeSubscriptionPurchase.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1459540113244,
        expiry_time_millis: (two_days_from_now.to_time.to_i * 1000),
        auto_renewing: true,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 0,
        payment_state: 1,
      )
    end

    it "is expired?" do
      subject.expired?.must_be_false
    end

    it "is two days left until it is overdue" do
      subject.overdue_days.must_equal(-2)
    end
  end

  describe "expired due to payment failure" do
    let(:fake_subscription_purchase) do
      FakeSubscriptionPurchase.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1459540113244,
        expiry_time_millis: 1462132088610,
        auto_renewing: true,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 1,
        payment_state: 1,
      )
    end

    it "is expired?" do
      subject.expired?.must_be_true
    end

    it "is payment_failed?" do
      subject.payment_failed?.must_be_true
    end
  end

  describe "subscription cancelation by user" do
    describe "when subscription is not canceled" do
      let(:fake_subscription_purchase) do
        FakeSubscriptionPurchase.new(
          kind: "androidpublisher#subscriptionPurchase",
          start_time_millis: 1459540113244,
          expiry_time_millis: 1462132088610,
          auto_renewing: true,
          developer_payload: "payload that gets stored and returned",
          payment_state: 1,
        )
      end

      it "is not canceled?" do
        subject.canceled_by_user?.must_be_false
      end

      it "returns blank user_cancellation_time_millis" do
        subject.user_cancellation_time_millis.must_be_nil
      end

      it "returns blank canceled_at" do
        subject.canceled_at.must_be_nil
      end
    end

    describe "when subscription is canceled" do
      let(:fake_subscription_purchase) do
        FakeSubscriptionPurchase.new(
          kind: "androidpublisher#subscriptionPurchase",
          start_time_millis: 1459540113244,
          expiry_time_millis: 1462132088610,
          user_cancellation_time_millis: 1461872888000,
          auto_renewing: true,
          developer_payload: "payload that gets stored and returned",
          cancel_reason: 0,
          payment_state: 1,
        )
      end

      it "is canceled?" do
        subject.canceled_by_user?.must_be_true
      end

      it "returns the user_cancellation_time_millis" do
        subject.user_cancellation_time_millis.must_equal 1_461_872_888_000
      end

      it "returns the starts_at" do
        expected = DateTime.new(2016, 4, 28, 19, 48, 8)
        subject.canceled_at.must_equal expected
      end
    end
  end

  describe "expired with pending payment" do
    let(:fake_subscription_purchase) do
      FakeSubscriptionPurchase.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1459540113244,
        expiry_time_millis: 1462132088610,
        auto_renewing: true,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 0,
        payment_state: 0,
      )
    end

    it "is expired?" do
      subject.expired?.must_be_true
    end

    it "is payment_pending?" do
      subject.payment_pending?.must_be_true
    end
  end

  describe "trial" do
    let(:fake_subscription_purchase) do
      FakeSubscriptionPurchase.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1459540113244,
        expiry_time_millis: 1462132088610,
        auto_renewing: false,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 0,
        payment_state: 1,
        price_currency_code: "SOMECODE",
        price_amount_micros: 0,
      )
    end

    it "is trial?" do
      subject.trial?.must_be_true
    end

    it "returns the price_currency_code" do
      subject.price_currency_code.must_equal "SOMECODE"
    end
  end

  private

  class FakeSubscriptionPurchase
    FIELDS = [
      :kind,
      :start_time_millis,
      :expiry_time_millis,
      :user_cancellation_time_millis,
      :auto_renewing,
      :developer_payload,
      :cancel_reason,
      :payment_state,
      :price_amount_micros,
      :price_currency_code,
    ].freeze

    attr_accessor *FIELDS

    def initialize(hash)
      FIELDS.each do |key|
        self.public_send("#{key}=", hash[key])
      end
    end
  end
end
