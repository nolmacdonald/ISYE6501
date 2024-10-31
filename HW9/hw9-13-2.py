import random
import simpy
import matplotlib.pyplot as plt


# Class representing the security system
class SecuritySystem:
    def __init__(self, env, num_scanners, num_servers):
        self.env = env
        self.server = simpy.Resource(env, num_servers)  # Boarding pass checkers
        self.scanner = [simpy.Resource(env, 1) for _ in range(num_scanners)]  # Scanners

    # Process for checking boarding pass
    def checkBoardingPass(self, serviceTime):
        yield self.env.timeout(random.expovariate(1.0 / serviceTime))

    # Process for scanning a person
    def scanPerson(self, minScan, maxScan):
        yield self.env.timeout(random.uniform(minScan, maxScan))


# Class representing a passenger
class Passenger:
    def __init__(self, env, name, system, simulation, serviceTime, minScan, maxScan):
        self.env = env
        self.name = name
        self.system = system
        self.simulation = simulation
        self.serviceTime = serviceTime
        self.minScan = minScan
        self.maxScan = maxScan
        self.action = env.process(self.run())  # Start the passenger process

    # Process for a passenger going through the system
    def run(self):
        timeArrive = self.env.now

        # Request to check boarding pass
        with self.system.server.request() as request:
            yield request
            tIn = self.env.now
            yield self.env.process(self.system.checkBoardingPass(self.serviceTime))
            tOut = self.env.now
            self.simulation.checkTime.append(tOut - tIn)

        # Find the scanner with the shortest queue
        minq = min(
            range(len(self.system.scanner)),
            key=lambda i: len(self.system.scanner[i].queue),
        )

        # Request to scan
        with self.system.scanner[minq].request() as request:
            yield request
            tIn = self.env.now
            yield self.env.process(self.system.scanPerson(self.minScan, self.maxScan))
            tOut = self.env.now
            self.simulation.scanTime.append(tOut - tIn)

        timeLeave = self.env.now
        self.simulation.sysTime.append(timeLeave - timeArrive)
        self.simulation.totThrough += 1


# Class representing the simulation
class Simulation:
    def __init__(
        self,
        numCheckers,
        numScanners,
        arrivalRate,
        serviceTime,
        minScan,
        maxScan,
        runTime,
        replications,
    ):
        self.numCheckers = numCheckers
        self.numScanners = numScanners
        self.arrivalRate = arrivalRate
        self.serviceTime = serviceTime
        self.minScan = minScan
        self.maxScan = maxScan
        self.runTime = runTime
        self.replications = replications
        self.avgCheckTime = []
        self.avgScanTime = []
        self.avgWaitTime = []
        self.avgSystemTime = []

    # Setup the simulation environment
    def setup(self, env):
        self.totThrough = 0
        self.checkTime = []
        self.scanTime = []
        self.sysTime = []
        system = SecuritySystem(env, self.numScanners, self.numCheckers)
        i = 0
        while True:
            yield env.timeout(random.expovariate(self.arrivalRate))
            i += 1
            Passenger(
                env,
                f"Passenger {i}",
                system,
                self,
                self.serviceTime,
                self.minScan,
                self.maxScan,
            )

    # Run the simulation
    def run(self):
        for i in range(self.replications):
            random.seed(i)
            env = simpy.Environment()
            env.process(self.setup(env))
            env.run(until=self.runTime)

            self.avgSystemTime.append(sum(self.sysTime) / self.totThrough)
            self.avgCheckTime.append(sum(self.checkTime) / self.totThrough)
            self.avgScanTime.append(sum(self.scanTime) / self.totThrough)
            self.avgWaitTime.append(
                self.avgSystemTime[i] - self.avgCheckTime[i] - self.avgScanTime[i]
            )

            print(
                f"{self.totThrough} : Replication {i+1} times {self.avgSystemTime[i]:.2f} {self.avgCheckTime[i]:.2f} {self.avgScanTime[i]:.2f} {self.avgWaitTime[i]:.2f}"
            )

        print("-----")
        print(
            f"Average system time = {sum(self.avgSystemTime) / self.replications:.2f}"
        )
        print(f"Average check time = {sum(self.avgCheckTime) / self.replications:.2f}")
        print(f"Average scan time = {sum(self.avgScanTime) / self.replications:.2f}")
        print(f"Average wait time = {sum(self.avgWaitTime) / self.replications:.2f}")

    # Plot the results of the simulation
    def plot_results(self):
        plt.figure(figsize=(12, 8))

        # Top left plot
        plt.subplot(2, 2, 1)
        plt.plot(self.avgSystemTime, label="Avg. System Time")
        plt.xlabel("Replication")
        plt.ylabel("Time (minutes)")
        plt.title("Average System Time")
        plt.legend()
        plt.grid()

        # Top right plot
        plt.subplot(2, 2, 2)
        plt.plot(self.avgCheckTime, label="Avg. Check Time")
        plt.xlabel("Replication")
        plt.ylabel("Time (minutes)")
        plt.title("Average Check Time")
        plt.legend()
        plt.grid()

        # Bottom left plot
        plt.subplot(2, 2, 3)
        plt.plot(self.avgScanTime, label="Avg. Scan Time")
        plt.xlabel("Replication")
        plt.ylabel("Time (minutes)")
        plt.title("Average Scan Time")
        plt.legend()
        plt.grid()

        # Bottom right plot
        plt.subplot(2, 2, 4)
        plt.plot(self.avgWaitTime, label="Avg. Wait Time")
        plt.xlabel("Replication")
        plt.ylabel("Time (minutes)")
        plt.title("Average Wait Time")
        plt.legend()
        plt.grid()

        plt.tight_layout()
        plt.show()

    # Plot histogram of system times
    def plot_histogram(self):
        plt.figure(figsize=(12, 8))

        plt.hist(self.sysTime, bins=30, alpha=0.7, label="System Time")
        plt.xlabel("Time (minutes)")
        plt.ylabel("Frequency")
        plt.title("Histogram of System Times")
        plt.legend()

        plt.show()


# Main function to run the simulation
if __name__ == "__main__":
    # ID/Boarding Pass Checkers
    numCheckers = 3
    # Scanners
    numScanners = 3
    arrivalRate = 5
    serviceTime = 0.75
    # Uniform distribution for scanner time
    minScan = 0.5  # Minimum time
    maxScan = 1.0  # Maximum time
    # Run time and iterations
    runTime = 720  # Run for X minutes
    replications = 100  # Number of runs

    sim = Simulation(
        numCheckers,
        numScanners,
        arrivalRate,
        serviceTime,
        minScan,
        maxScan,
        runTime,
        replications,
    )
    sim.run()
    sim.plot_results()
    sim.plot_histogram()
