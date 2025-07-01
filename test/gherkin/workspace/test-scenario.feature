Feature: Shopping Cart Functionality
  As an online shopper
  I want to manage items in my shopping cart
  So that I can purchase the products I need

  Background:
    Given the online store is operational
    And I am logged in as a registered user
    And my shopping cart is empty

  Rule: Users must be logged in to add items to cart
    Example: Adding an item to cart as a logged-in user
      When I browse to the "Electronics" category
      And I select the "Smartphone" product
      Then I should see the product details
      And the "Add to Cart" button should be enabled
      When I click the "Add to Cart" button
      Then 1 item should be added to my cart
      And I should see a confirmation message

  Rule: Cart total must be calculated correctly
    Scenario Outline: Verifying cart calculations with different quantities
      Given I have added a "<product>" with price $<price> to my cart
      When I update the quantity to <quantity>
      Then the item subtotal should be $<subtotal>
      And the cart total should include the subtotal

      Examples:
        | product    | price | quantity | subtotal |
        | Headphones | 50.00 | 2        | 100.00   |
        | Charger    | 25.00 | 3        | 75.00    |
        | Case       | 15.99 | 1        | 15.99    |

  Rule: Users can adjust quantities of items in cart
    Scenario: Increasing item quantity
      Given I have added a "Tablet" with price $199.99 to my cart
      When I increase the quantity to 2
      Then the cart should contain 2 "Tablet" items
      And the item subtotal should be $399.98

    Scenario: Removing an item from the cart
      Given I have added a "Laptop" with price $899.99 to my cart
      When I click the "Remove" button for this item
      Then the item should be removed from my cart
      And my cart should be empty
      But the item should be available for future purchase

  Rule: Checkout process requires valid payment information
    @critical @payment
    Scenario: Proceeding to checkout with valid payment details
      Given I have added a "Monitor" with price $249.99 to my cart
      And I have proceeded to the checkout page
      When I enter valid shipping information
      And I enter valid payment details
        | Card Type | Card Number      | Expiry Date | CVV |
        | Visa      | 4111111111111111 | 12/25       | 123 |
      And I confirm the order
      Then I should see an order confirmation
      And I should receive an email receipt
      * My cart should be empty after purchase
