package com.enginebeats.api.modules.billing.repository;

import com.enginebeats.api.modules.billing.entity.UserEntitlementEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserEntitlementRepository extends JpaRepository<UserEntitlementEntity, UUID> {
    Optional<UserEntitlementEntity> findByUserId(String userId);
    Optional<UserEntitlementEntity> findByStripeCustomerId(String stripeCustomerId);
    Optional<UserEntitlementEntity> findByStripeSubscriptionId(String stripeSubscriptionId);
}
