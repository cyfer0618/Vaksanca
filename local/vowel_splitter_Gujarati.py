import re

#'s/([^aAiIuUfFxXeEoO ]{0,1}[aAiIuUfFxXeEoO]([kKgGNcCjJYwWqQRtTdDnpPbBmyrlLvSzshMH](?![aAiIuUfFxXeEoO]))*)/\1-/g;s/\- / /g' sample.txt

def CiE(i,s,ss):
	# print(i,s,ss)
	n=len(s)
	if i>=n:
		# print(i,s,ss,"i>=n, so False")
		return False
	else:
		if s[i] in ss:
			# print(i,s,ss,"found, so True")
			return True
		else:
			# print(i,s,ss,"not found, so False")
			return False

def CiFV(i,s,ss):
	if(i>=len(s)):
		return False
	elif s[i] in ss:
		for c in ss:
			if c in s:
				x=s.index(c)
				if(x<i):
					# print(i,x,s,ss,"False")
					return False
		# print(i,s,ss,"True")
		return True



vowels='aAiIuUfFxXeZEoVO'#'aAiIuUfFxXeEoO'
consonants='kKgGNcCjJYwWqQRtTdDnpPbBmyrlvSzshLMH~'#'kKgGNcCjJYwWqQRtTdDnpPbBmyrlLvSzshMH'
charset=vowels+consonants
f=open('6','r')
sss=f.readlines()
#tasya rAjanItikuSalatAM tAvat anupamA duHKaH eva tArkzya aMzaH tryakzaH
for ss in sss:
	s1=ss.split()
	# s1=re.sub(r"([^aAiIuUfFxXeEoO ]{0,1}[aAiIuUfFxXeEoO]([kKgGNcCjJYwWqQRtTdDnpPbBmyrlLvSzshMH](?![aAiIuUfFxXeEoO]))*)",r"\1-",s)
	# output=re.sub(r"\- "," ",s1)
	line=""
	for s in s1:
		output=''
		i=0
		first_flag=False
		for i in range(len(s)):
			# print(i,output)
			c=s[i]
			# if c not in charset:

			if CiE(i,s,vowels):
				# print("begin_vowel ",c,i,output)
				if CiE(i+1,s,vowels):
					output+=c+'++'
				elif CiE(i+1,s,consonants) and CiE(i+2,s,consonants):
					output+=c
				elif CiE(i+1,s,consonants) and CiE(i+2,s,vowels):
					output+=c+'++'
				else:
					output+=c
				first_flag=True
				# print("end_vowel ",c,i,output)
			if CiE(i,s,consonants):
				# print("begin_consonant ",c,i,output)
				if CiE(i+1,s,vowels):
					output+=c
					first_flag=True
				elif CiE(i+1,s,consonants) and CiE(i+2,s,consonants):
					output+=c
				# elif CiE(i+1,s,consonants) and CiE(i+2,s,vowels) and ((' ' not in output) and (first_flag==False)):
				elif CiE(i+1,s,consonants) and CiE(i+2,s,vowels) and CiFV(i+2,s,vowels):
					output+=c
					# first_flag=True
				elif CiE(i+1,s,consonants) and CiE(i+2,s,vowels):
					output+=c+'++'
				else:
					output+=c
				# print("end_consonant ",c,i,output)
			i+=1
		# print(s," : ",output)
		if output != "":
			line+=output+"++"+" "
		else:
			line+=s+" "
	print(line[:-1])