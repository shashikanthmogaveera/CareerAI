@echo off                                        
title CareerAI Backend [port 5000]              
color 0B                                        
chcp 65001 >nul                                
set PYTHONIOENCODING=utf-8                      
echo.                                           
echo  Backend -> http://localhost:5000          
echo  Close this window to stop the backend.   
echo.                                           
cd /d "C:\Users\shash\Desktop\Project4\Intelligent_Career_Guidance_Project\career-guidance-ui"                                  
"C:\Users\shash\Desktop\Project4\Intelligent_Career_Guidance_Project\career-guidance-ui\venv\Scripts\python.exe" flask_cors_config.py                
pause                                           
