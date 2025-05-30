#!/bin/bash
#
# This script optimizes system performance by adjusting IRQ affinities and network interface settings.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting system tuning script..."

# --- IRQ Affinity Tuning ---
echo "--- Tuning IRQ affinities ---"

# Get the number of online CPU cores.
# We'll use this to dynamically calculate smp_affinity masks.
NUM_CPUS=$(nproc)

# Calculate affinity masks.
# For example, if 4 CPUs:
# - ALL_CPUS_MASK (all cores): 0xf (1111 in binary)
# - CPU_0_MASK (core 0): 0x1
# - LAST_CPU_MASK (last core): 0x8 (if 4 cores, core 3)
# - ALL_BUT_LAST_CPU_MASK (all cores except the last): 0x7 (if 4 cores, cores 0,1,2)

# This creates a bitmask for all CPUs (e.g., 0x01, 0x03, 0x07, 0x0f, 0x1f, etc.)
ALL_CPUS_MASK=$(printf '0x%x' $(( (1 << NUM_CPUS) - 1 )))

# Assign the last CPU for specific IRQs (e.g., USB3)
# This assumes we want to dedicate the last core to USB3 to prevent contention.
# For N CPUs, the last CPU's bitmask is 1 << (N-1)
LAST_CPU_MASK=$(printf '0x%x' $(( 1 << (NUM_CPUS - 1) )))

# Assign all CPUs except the last one for other IRQs.
# This assigns the remaining cores for general IRQ processing.
ALL_BUT_LAST_CPU_MASK=$(printf '0x%x' $(( ALL_CPUS_MASK ^ LAST_CPU_MASK )))

echo "Detected ${NUM_CPUS} CPU cores."
echo "Calculated ALL_CPUS_MASK: ${ALL_CPUS_MASK}"
echo "Calculated LAST_CPU_MASK (for USB3): ${LAST_CPU_MASK}"
echo "Calculated ALL_BUT_LAST_CPU_MASK (for other IRQs): ${ALL_BUT_LAST_CPU_MASK}"

# Get all IRQ numbers, excluding the 'default' directory.
INTERRUPTS=$(ls /proc/irq/ | grep -v 'default' || true) # Use '|| true' to prevent error if grep returns no match

if [[ -z "$INTERRUPTS" ]]; then
    echo "No IRQ directories found in /proc/irq/."
else
    # Get the IRQ number for USB3. This looks for lines containing 'usb3' in /proc/interrupts.
    USB3_NUMBER=$(grep usb3 /proc/interrupts | awk -F: '{print $1}' | sed 's/^ //g' || true)

    if [[ -z "$USB3_NUMBER" ]]; then
        echo "No USB3 interrupt found. Skipping USB3 IRQ affinity tuning."
    else
        echo "USB3 interrupt number: ${USB3_NUMBER}"
    fi

    for i in ${INTERRUPTS}; do
        IRQ_SMP_AFFINITY_PATH="/proc/irq/$i/smp_affinity"
        if [[ -e "$IRQ_SMP_AFFINITY_PATH" ]]; then
            if [[ "$i" = "$USB3_NUMBER" ]]; then
                echo "${LAST_CPU_MASK}" > "${IRQ_SMP_AFFINITY_PATH}" 2>/dev/null \
                    && echo "Set IRQ ${i} (USB3) smp_affinity to ${LAST_CPU_MASK}" \
                    || echo "Failed to set IRQ ${i} (USB3) smp_affinity."
            else
                echo "${ALL_BUT_LAST_CPU_MASK}" > "${IRQ_SMP_AFFINITY_PATH}" 2>/dev/null \
                    && echo "Set IRQ ${i} smp_affinity to ${ALL_BUT_LAST_CPU_MASK}" \
                    || echo "Failed to set IRQ ${i} smp_affinity."
            fi
        else
            echo "Warning: ${IRQ_SMP_AFFINITY_PATH} does not exist for IRQ ${i}. Skipping."
        fi
    done
fi

# --- Network Interface Tuning ---
echo "--- Tuning Network Interfaces ---"

# Get a list of all network interfaces.
IFACES=$(ls /sys/class/net || true)

if [[ -z "$IFACES" ]]; then
    echo "No network interfaces found in /sys/class/net/."
else
    # Calculate rps_cpus mask for all but the last CPU, similar to general IRQ affinity.
    # This assigns Receive Packet Steering to all cores except the last one, to avoid conflict with USB3 IRQs.
    RPS_CPUS_MASK="${ALL_BUT_LAST_CPU_MASK}" # You might adjust this based on specific needs.

    echo "Calculated RPS_CPUS_MASK: ${RPS_CPUS_MASK}"

    for i in ${IFACES}; do
        echo "Processing interface: ${i}"

        # Enable Generic Receive Offload (GRO)
        if ethtool -K "$i" gro on 2>/dev/null; then
            echo "Enabled GRO for ${i}."
        else
            echo "Warning: Could not enable GRO for ${i}. (ethtool might not be installed or interface doesn't support GRO)"
        fi

        # Configure Receive Packet Steering (RPS)
        RPS_CPUS_PATH="/sys/class/net/$i/queues/rx-0/rps_cpus"
        if [[ -e "$RPS_CPUS_PATH" ]]; then
            # The original script had a special case for "wwan0" but assigned the same value.
            # This simplified version assigns the same mask to all, but you can re-introduce
            # special logic if different masks are truly needed for specific interfaces.
            echo "${RPS_CPUS_MASK}" > "${RPS_CPUS_PATH}" 2>/dev/null \
                && echo "Set RPS CPUs for ${i} (rx-0) to ${RPS_CPUS_MASK}." \
                || echo "Failed to set RPS CPUs for ${i} (rx-0)."
        else
            echo "Info: ${RPS_CPUS_PATH} does not exist for ${i}. Skipping RPS configuration."
        fi
    done
fi

echo "System tuning script finished."
