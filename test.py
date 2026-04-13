import asyncio

async def task(n):
    print("Start task ", n)
    await asyncio.sleep(2)
    print("End task ", n)
    
async def main():
    await asyncio.gather(
        task(1),
        task(3)
    )
    print("End tasks")
    
asyncio.run(main())