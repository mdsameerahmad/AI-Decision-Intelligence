class AgentService:

    def generate_action_plan(self, insight: str):

        tasks = [
            "Investigate root cause of the issue",
            "Design strategy to resolve the problem",
            "Implement solution with engineering team",
            "Track performance metrics after changes"
        ]

        return {
            "insight": insight,
            "recommended_tasks": tasks
        }