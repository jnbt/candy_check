require "spec_helper"

describe CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase do
  subject { CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase.new(fake_subscription_purchase) }

  describe "expired and canceled subscription" do
    let(:fake_subscription_purchase) do
      OpenStruct.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1_459_540_113_244,
        expiry_time_millis: 1_462_132_088_610,
        auto_renewing: false,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 0,
        payment_state: 1,
      )
    end

    it "is expired?" do
      _(subject.expired?).must_be_true
    end

    it "is canceled by user" do
      _(subject.canceled_by_user?).must_be_true
    end

    it "returns the payment_state" do
      _(subject.payment_state).must_equal 1
    end

    it "considers a payment as valid" do
      _(subject.payment_received?).must_be_true
    end

    it "checks that auto renewal status is false" do
      _(subject.auto_renewing?).must_be_false
    end

    it "returns the developer_payload" do
      _(subject.developer_payload).must_equal \
        "payload that gets stored and returned"
    end

    it "returns the kind" do
      _(subject.kind).must_equal "androidpublisher#subscriptionPurchase"
    end

    it "returns the start_time_millis" do
      _(subject.start_time_millis).must_equal 145_954_011_324_4
    end

    it "returns the expiry_time_millis" do
      _(subject.expiry_time_millis).must_equal 146_213_208_861_0
    end

    it "returns the starts_at" do
      expected = DateTime.new(2016, 4, 1, 19, 48, 33)
      _(subject.starts_at).must_equal expected
    end

    it "returns the expires_at" do
      expected = DateTime.new(2016, 5, 1, 19, 48, 8)
      _(subject.expires_at).must_equal expected
    end
  end

  describe "unexpired and renewing subscription" do
    two_days_from_now = DateTime.now + 2

    let(:fake_subscription_purchase) do
      OpenStruct.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1_459_540_113_244,
        expiry_time_millis: (two_days_from_now.to_time.to_i * 1000),
        auto_renewing: true,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 0,
        payment_state: 1,
      )
    end

    it "is expired?" do
      _(subject.expired?).must_be_false
    end

    it "is two days left until it is overdue" do
      _(subject.overdue_days).must_equal(-2)
    end
  end

  describe "expired due to payment failure" do
    let(:fake_subscription_purchase) do
      OpenStruct.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1_459_540_113_244,
        expiry_time_millis: 1_462_132_088_610,
        auto_renewing: true,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 1,
        payment_state: 1,
      )
    end

    it "is expired?" do
      _(subject.expired?).must_be_true
    end

    it "is payment_failed?" do
      _(subject.payment_failed?).must_be_true
    end
  end

  describe "subscription cancelation by user" do
    describe "when subscription is not canceled" do
      let(:fake_subscription_purchase) do
        OpenStruct.new(
          kind: "androidpublisher#subscriptionPurchase",
          start_time_millis: 1_459_540_113_244,
          expiry_time_millis: 1_462_132_088_610,
          auto_renewing: true,
          developer_payload: "payload that gets stored and returned",
          payment_state: 1,
        )
      end

      it "is not canceled?" do
        _(subject.canceled_by_user?).must_be_false
      end

      it "returns nil user_cancellation_time_millis" do
        _(subject.user_cancellation_time_millis).must_be_nil
      end

      it "returns nil canceled_at" do
        _(subject.canceled_at).must_be_nil
      end
    end

    describe "when subscription is canceled" do
      let(:fake_subscription_purchase) do
        OpenStruct.new(
          kind: "androidpublisher#subscriptionPurchase",
          start_time_millis: 1_459_540_113_244,
          expiry_time_millis: 1_462_132_088_610,
          user_cancellation_time_millis: 1_461_872_888_000,
          auto_renewing: true,
          developer_payload: "payload that gets stored and returned",
          cancel_reason: 0,
          payment_state: 1,
        )
      end

      it "is canceled?" do
        _(subject.canceled_by_user?).must_be_true
      end

      it "returns the user_cancellation_time_millis" do
        _(subject.user_cancellation_time_millis).must_equal 1_461_872_888_000
      end

      it "returns the starts_at" do
        expected = DateTime.new(2016, 4, 28, 19, 48, 8)
        _(subject.canceled_at).must_equal expected
      end
    end
  end

  describe "expired with pending payment" do
    let(:fake_subscription_purchase) do
      OpenStruct.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1_459_540_113_244,
        expiry_time_millis: 1_462_132_088_610,
        auto_renewing: true,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 0,
        payment_state: 0,
      )
    end

    it "is expired?" do
      _(subject.expired?).must_be_true
    end

    it "is payment_pending?" do
      _(subject.payment_pending?).must_be_true
    end
  end

  describe "trial" do
    let(:fake_subscription_purchase) do
      OpenStruct.new(
        kind: "androidpublisher#subscriptionPurchase",
        start_time_millis: 1_459_540_113_244,
        expiry_time_millis: 1_462_132_088_610,
        auto_renewing: false,
        developer_payload: "payload that gets stored and returned",
        cancel_reason: 0,
        payment_state: 1,
        price_currency_code: "SOMECODE",
        price_amount_micros: 0,
      )
    end

    it "is trial?" do
      _(subject.trial?).must_be_true
    end

    it "returns the price_currency_code" do
      _(subject.price_currency_code).must_equal "SOMECODE"
    end
  end
end
