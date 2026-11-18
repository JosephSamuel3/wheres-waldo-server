-- CreateEnum
CREATE TYPE "Difficulty" AS ENUM ('easy', 'medium', 'hard');

-- CreateEnum
CREATE TYPE "GameStatus" AS ENUM ('inProgress', 'abandoned', 'completed');

-- CreateTable
CREATE TABLE "GameSession" (
    "id" UUID NOT NULL,
    "difficulty" "Difficulty" NOT NULL,
    "durationMs" INTEGER,
    "status" "GameStatus" NOT NULL DEFAULT 'inProgress',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "completedAt" TIMESTAMP(3),
    "abandonedAt" TIMESTAMP(3),

    CONSTRAINT "GameSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FoundTarget" (
    "id" UUID NOT NULL,
    "gameSessionId" UUID NOT NULL,
    "targetId" TEXT NOT NULL,
    "foundAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FoundTarget_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LeaderboardEntry" (
    "id" UUID NOT NULL,
    "playerName" VARCHAR(30) NOT NULL,
    "gameSessionId" UUID NOT NULL,
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LeaderboardEntry_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "FoundTarget_gameSessionId_targetId_key" ON "FoundTarget"("gameSessionId", "targetId");

-- CreateIndex
CREATE UNIQUE INDEX "LeaderboardEntry_gameSessionId_key" ON "LeaderboardEntry"("gameSessionId");

-- AddForeignKey
ALTER TABLE "FoundTarget" ADD CONSTRAINT "FoundTarget_gameSessionId_fkey" FOREIGN KEY ("gameSessionId") REFERENCES "GameSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LeaderboardEntry" ADD CONSTRAINT "LeaderboardEntry_gameSessionId_fkey" FOREIGN KEY ("gameSessionId") REFERENCES "GameSession"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
