import os
import sys
import time
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class ChangeHandler(FileSystemEventHandler):
    def __init__(self):
        super().__init__()
        self.last_change = time.time()
        self.script_triggered = False
        self.change_detected = False

    def on_closed(self, event):
        self.on(event)

    def on_deleted(self, event):
        self.on(event)

    def on_created(self, event):
        self.on(event)

    def on_moved(self, event):
        self.on(event)

    def on(self, event):
        if not event.is_directory:  # 忽略目录变更通知
            self.last_change = time.time()
            self.change_detected = True
            self.script_triggered = False


def monitor_directory():
    event_handler = ChangeHandler()
    observer = Observer()
    observer.schedule(event_handler, path='.', recursive=True)
    observer.start()

    try:
        while True:
            i = 0
            while not event_handler.change_detected:
                i += 1
                print(f"\r等待更改{i*'.'}", end="", flush=True)
                if i >= 3:
                    i = 0
                time.sleep(0.1)
            current_time = time.time()
            time_since_last_change = current_time - event_handler.last_change

            # 如果3秒内没有检测到更改，但之前有更改发生
            if time_since_last_change > 1 and event_handler.change_detected and not event_handler.script_triggered:
                print(f"\n检测到{time_since_last_change:.1f}秒无连续更改，执行脚本...")
                try:
                    subprocess.run(
                        ["bash", "./run.sh"], check=True, stderr=sys.stderr, stdout=sys.stdout, stdin=sys.stdin)
                except:
                    pass
                event_handler.script_triggered = True
                event_handler.change_detected = False  # 重置更改检测标志
                print("脚本已执行完毕!")
            else:
                # 实时显示监控状态
                status = "等待更改..." if not event_handler.change_detected else (
                    f"更改后静默: {time_since_last_change:.1f}s" if time_since_last_change < 3
                    else f"准备执行: {time_since_last_change:.1f}s"
                )
                print(
                    f"\r监控状态: {status} | 上次触发: {'是' if event_handler.script_triggered else '否'}", end="", flush=True)

            time.sleep(0.1)  # 更频繁地检查（每0.1秒）
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


if __name__ == "__main__":
    print(f"开始监控目录: {os.getcwd()}")
    print("规则: 检测到更改后，需3秒无连续更改才执行./run.sh")
    monitor_directory()
