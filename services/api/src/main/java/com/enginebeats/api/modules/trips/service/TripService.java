package com.enginebeats.api.modules.trips.service;

import com.enginebeats.api.common.exception.ResourceNotFoundException;
import com.enginebeats.api.modules.trips.dto.EndTripRequest;
import com.enginebeats.api.modules.trips.dto.StartTripRequest;
import com.enginebeats.api.modules.trips.dto.TripResponse;
import com.enginebeats.api.modules.trips.entity.TripEntity;
import com.enginebeats.api.modules.trips.repository.TripRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TripService {

    private final TripRepository tripRepository;

    @Transactional(readOnly = true)
    public List<TripResponse> getTrips(String userId, UUID vehicleId) {
        List<TripEntity> list = (vehicleId != null)
                ? tripRepository.findByUserIdAndVehicleIdOrderByStartedAtDesc(userId, vehicleId)
                : tripRepository.findByUserIdOrderByStartedAtDesc(userId);

        return list.stream().map(TripResponse::fromEntity).toList();
    }

    @Transactional(readOnly = true)
    public TripResponse getTripById(UUID id, String userId) {
        TripEntity trip = tripRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Trip not found with id: " + id));
        return TripResponse.fromEntity(trip);
    }

    @Transactional
    public TripResponse startTrip(StartTripRequest request, String userId) {
        TripEntity trip = TripEntity.builder()
                .vehicleId(request.vehicleId())
                .userId(userId)
                .title(request.title() != null ? request.title() : "Trip " + Instant.now())
                .startedAt(Instant.now())
                .status("IN_PROGRESS")
                .build();

        TripEntity saved = tripRepository.save(trip);
        return TripResponse.fromEntity(saved);
    }

    @Transactional
    public TripResponse endTrip(UUID tripId, EndTripRequest request, String userId) {
        TripEntity trip = tripRepository.findByIdAndUserId(tripId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Trip not found with id: " + tripId));

        trip.setEndedAt(Instant.now());
        trip.setStatus("COMPLETED");
        if (request != null) {
            if (request.distanceKm() != null) trip.setDistanceKm(request.distanceKm());
            if (request.maxSpeedKmh() != null) trip.setMaxSpeedKmh(request.maxSpeedKmh());
            if (request.avgSpeedKmh() != null) trip.setAvgSpeedKmh(request.avgSpeedKmh());
            if (request.fuelConsumedLiters() != null) trip.setFuelConsumedLiters(request.fuelConsumedLiters());
        }

        TripEntity saved = tripRepository.save(trip);
        return TripResponse.fromEntity(saved);
    }
}
