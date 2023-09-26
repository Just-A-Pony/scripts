#!/usr/bin/env python3
import asyncio
import json
import logging
import re
from playwright.async_api import async_playwright
parallel=int(input('并发操作数'))
url=input('网站:端口')
path=input('tcping or tcping_ipv6')
urls='https://www.itdog.cn/'+path+'/'+url
# 设置日志级别和格式
logging.basicConfig(level=logging.DEBUG, format="%(asctime)s - %(levelname)s - %(message)s")
async def open_web():
    async with async_playwright() as pw:
        try:
            logging.info("Launching browser and creating page")
            browser = await pw.chromium.launch(headless=False)
            context = await browser.new_context()
            async with browser, context:
                page = await context.new_page()
                logging.info("Opening website")
                await page.goto(urls,timeout=600000)
                await page.get_by_role("button", name=" 单次测试").click(timeout=60000)
                await page.get_by_role("link", name=" 持续测试").click(timeout=60000)
                await page.get_by_role("button", name=" 开始测试").click(timeout=6000000)
                logging.info("GO")
                await asyncio.sleep(120)
                logging.info("OK")
        except Exception as e:
            logging.error(e)
async def main():
    tasks = [open_web() for _ in range(parallel)]
    for task in asyncio.as_completed(tasks):
        result = await task
        logging.info(result)
asyncio.run(main())
exit()
